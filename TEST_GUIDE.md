# 抽奖系统测试方案

本文档提供完整的测试流程，帮助你验证抽奖系统的接口正确性。

---

## 测试环境准备

### 前置条件
- 已安装 Docker 和 Docker Compose
- 已安装 MySQL 客户端（可选，用于直接查询数据库）
- 已安装 curl 或 PowerShell（用于接口测试）

---

## 步骤一：启动服务

### 1. 启动 Docker Compose

在项目根目录执行：

```bash
docker-compose up --build -d
```

### 2. 检查服务状态

```bash
docker-compose ps
```

应该看到三个服务都在运行：
- `lottery_mysql` (端口 3307)
- `lottery_redis` (端口 6379)
- `lottery_app` (端口 8081)

### 3. 查看应用日志

```bash
docker-compose logs -f app
```

如果看到 "Server running on :8081" 说明服务启动成功。

---

## 步骤二：准备测试数据

### 方法一：使用提供的测试数据脚本

```bash
docker exec -i lottery_mysql mysql -uroot -p1234 lottery_single < test_data.sql
```

### 方法二：手动导入（如果方法一失败）

1. 进入 MySQL 容器：
```bash
docker exec -it lottery_mysql mysql -uroot -p1234
```

2. 复制 `test_data.sql` 的内容，粘贴到 MySQL 终端执行

### 验证数据导入

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
USE lottery_single;
SELECT '===== 用户列表 =====' as '';
SELECT id, user_name FROM t_user;
SELECT '===== 奖品列表 =====' as '';
SELECT id, title, prize_num, left_num, prize_code, prize_type FROM t_prize WHERE sys_status = 1;
SELECT '===== 优惠券数量 =====' as '';
SELECT COUNT(*) as coupon_count FROM t_coupon WHERE sys_status = 1;
"
```

应该看到：
- **2 个用户**：testuser, admin（密码都是 123456）
- **5 个奖品**：谢谢参与、10金币、50元优惠券、蓝牙耳机、iPhone 16 Pro
- **500 张优惠券**

---

## 步骤三：测试接口

### Windows 用户（使用 PowerShell）

```powershell
powershell -ExecutionPolicy Bypass -File test_api.ps1
```

### Linux/Mac 用户（使用 Bash）

```bash
chmod +x test_api.sh
bash test_api.sh
```

### 手动测试（使用 curl）

#### 1. 用户登录

```bash
curl -X POST http://localhost:8081/admin/login \
  -H "Content-Type: application/json" \
  -d '{"user_name":"testuser","pass_word":"123456"}'
```

**预期响应：**
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**复制返回的 token，用于后续请求。**

---

#### 2. 获取奖品列表

```bash
curl -X GET http://localhost:8081/admin/get_prize_list
```

**预期响应：**
```json
{
  "code": 200,
  "msg": "success",
  "data": [
    {
      "id": 1,
      "title": "谢谢参与",
      "prize_code": "0-4999",
      ...
    },
    ...
  ]
}
```

---

#### 3. 抽奖（V2 接口）

**将 `YOUR_TOKEN_HERE` 替换为步骤1获取的 token**

```bash
curl -X POST http://localhost:8081/lottery/v2/get_lucky \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN_HERE","user_id":1,"ip":"127.0.0.1"}'
```

**预期响应示例：**

中奖情况1（谢谢参与）：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "id": 1,
    "prize_name": "谢谢参与",
    "prize_type": 0
  }
}
```

中奖情况2（虚拟币）：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "id": 2,
    "prize_name": "10金币",
    "prize_type": 1,
    "prize_data": "{\"coins\": 10}"
  }
}
```

中奖情况3（优惠券）：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "id": 3,
    "prize_name": "50元优惠券",
    "prize_type": 2,
    "prize_data": "COUPON-000123"
  }
}
```

---

#### 4. 抽奖（V1 接口）

```bash
curl -X POST http://localhost:8081/lottery/v1/get_lucky \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN_HERE","user_id":1,"ip":"127.0.0.1"}'
```

---

## 步骤四：验证结果

### 1. 查看中奖记录

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT id, user_id, prize_name, prize_type, prize_data, sys_created
FROM lottery_single.t_result
ORDER BY id DESC
LIMIT 20;
"
```

### 2. 查看用户抽奖次数

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT * FROM lottery_single.t_lottery_times;
"
```

### 3. 查看奖品库存变化

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT id, title, prize_num, left_num, prize_type
FROM lottery_single.t_prize
WHERE sys_status = 1;
"
```

注意观察：
- **虚拟币**：prize_num 和 left_num 应该都是 0（无限量）
- **优惠券**：left_num 应该减少（如果中了优惠券）
- **实物奖品**：left_num 应该减少（如果中了实物）

### 4. 查看已发放的优惠券

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT id, prize_id, code, sys_status
FROM lottery_single.t_coupon
WHERE sys_status = 3
LIMIT 10;
"
```

sys_status = 3 表示已发放的优惠券。

---

## 步骤五：测试边界情况

### 1. 测试无效 Token

```bash
curl -X POST http://localhost:8081/lottery/v2/get_lucky \
  -H "Content-Type: application/json" \
  -d '{"token":"invalid_token","user_id":1,"ip":"127.0.0.1"}'
```

**预期：返回 401 或错误信息**

### 2. 测试抽奖次数限制

连续抽奖 3000 次以上，应该会返回"抽奖次数已用完"的错误。

可以使用循环测试：
```bash
for i in {1..3001}; do
  curl -X POST http://localhost:8081/lottery/v2/get_lucky \
    -H "Content-Type: application/json" \
    -d '{"token":"YOUR_TOKEN_HERE","user_id":1,"ip":"127.0.0.1"}' -s
done
```

### 3. 测试黑名单功能

添加测试用户到黑名单：
```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
INSERT INTO lottery_single.t_black_user (user_id, user_name, black_time, sys_created, sys_updated, sys_ip)
VALUES (1, 'testuser', '2026-12-31 23:59:59', NOW(), NOW(), '127.0.0.1');
"
```

再次抽奖，应该返回"用户已被拉黑"的错误。

---

## 步骤六：测试概率分布

执行 1000 次抽奖，查看概率分布是否符合预期：

```bash
# 执行 1000 次抽奖（PowerShell）
for ($i = 1; $i -le 1000; $i++) {
  curl -X POST http://localhost:8081/lottery/v2/get_lucky \
    -H "Content-Type: application/json" \
    -d '{"token":"YOUR_TOKEN_HERE","user_id":1,"ip":"127.0.0.1"}' -s
}

# 查看中奖分布
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT prize_name, COUNT(*) as count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM lottery_single.t_result), 2) as percentage
FROM lottery_single.t_result
GROUP BY prize_name
ORDER BY count DESC;
"
```

**预期分布：**
- 谢谢参与：约 50%
- 10金币：约 30%
- 50元优惠券：约 15%
- 蓝牙耳机：约 4%
- iPhone 16 Pro：约 1%

---

## 步骤七：清理测试数据

如果需要重新测试，可以清空数据：

```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
TRUNCATE TABLE lottery_single.t_result;
TRUNCATE TABLE lottery_single.t_lottery_times;
UPDATE lottery_single.t_prize SET left_num = prize_num WHERE prize_num > 0;
UPDATE lottery_single.t_coupon SET sys_status = 1;
"
```

---

## 常见问题

### Q1: 服务启动失败

**检查日志：**
```bash
docker-compose logs app
```

常见原因：
- MySQL 未完全启动（等待 30 秒后重试）
- 端口被占用（修改 docker-compose.yml 中的端口）

### Q2: 数据库连接失败

**检查 MySQL 是否运行：**
```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "SELECT 1;"
```

### Q3: 抽奖返回"未找到可用的优惠券"

**检查优惠券数量：**
```bash
docker exec -it lottery_mysql mysql -uroot -p1234 -e "
SELECT COUNT(*) FROM lottery_single.t_coupon WHERE prize_id = 3 AND sys_status = 1;
"
```

如果数量为 0，重新执行 test_data.sql。

### Q4: Token 验证失败

确保 token 格式正确，并且没有过期。重新登录获取新 token。

---

## 测试检查清单

- [ ] 服务成功启动
- [ ] 测试数据成功导入
- [ ] 用户登录成功，获取 token
- [ ] 获取奖品列表成功
- [ ] V2 抽奖接口正常工作
- [ ] V1 抽奖接口正常工作
- [ ] 中奖记录正确保存到数据库
- [ ] 奖品库存正确扣减
- [ ] 优惠券正确发放
- [ ] 抽奖次数限制生效
- [ ] 黑名单功能正常
- [ ] 无效 token 被拒绝
- [ ] 概率分布符合预期

---

## 总结

完成以上步骤后，你应该能够：
1. 理解抽奖系统的整体流程
2. 验证所有接口的正确性
3. 确认数据库操作正常
4. 测试边界情况和异常处理

如有问题，请查看日志：
```bash
docker-compose logs -f app
```
