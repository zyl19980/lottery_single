# 抽奖系统测试说明

## 问题修复说明

原来的测试数据中，bcrypt 密码哈希不正确。已经修复并重新导入数据。

**现在的测试账号：**
- 用户名：`testuser` 密码：`123456` ✅
- 用户名：`admin` 密码：`admin123` ✅

## 快速测试指令

### 1. 用户登录

```bash
curl -X POST http://localhost:8081/admin/login -H "Content-Type: application/json" -d "{\"user_name\":\"testuser\",\"pass_word\":\"123456\"}"
```

**成功响应示例：**
```json
{
  "code": 0,
  "msg": "ok",
  "data": {
    "user_id": 1,
    "token": "eyJhbGc..."
  }
}
```

复制返回的 `token` 用于后续请求。
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VyX25hbWUiOiJ0ZXN0dXNlciIsIlN0YW5kYXJkQ2xhaW1zIjp7ImV4cCI6MTc2NTk3MzE1MywiaXNzIjoibG90dGVyeSIsIm5iZiI6MTc2NTk2NTk1M319.hqC3jrNmgOCcFKbx8j2fspLPWuyi-eLmk7obSHuWgeo
---

### 2. 获取奖品列表

```bash
curl -X GET http://localhost:8081/admin/get_prize_list
```

---

### 3. 抽奖（V2 接口）

**将 `YOUR_TOKEN` 替换为登录返回的 token**

```bash
curl -X POST http://localhost:8081/lottery/v2/get_lucky -H "Content-Type: application/json" -d "{\"token\":\"YOUR_TOKEN\",\"user_id\":1,\"ip\":\"127.0.0.1\"}"
```

**中奖响应示例：**

虚拟币：
```json
{
  "code": 0,
  "msg": "ok",
  "data": {
    "id": 2,
    "title": "10金币",
    "prize_type": 1,
    "prize_profile": "{\"coins\": 10}"
  }
}
```

优惠券：
```json
{
  "code": 0,
  "msg": "ok",
  "data": {
    "id": 3,
    "title": "50元优惠券",
    "prize_type": 2,
    "prize_data": "COUPON-000123"
  }
}
```

未中奖/谢谢参与：
```json
{
  "code": 100010,
  "msg": "not won,please try again!",
  "data": null
}
```

---

### 4. 查看数据库结果

**查看中奖记录：**
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "SELECT id, user_id, prize_name, prize_type, prize_data FROM lottery_single.t_result ORDER BY id DESC LIMIT 10;"
```

**查看奖品库存：**
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "SELECT id, title, prize_num, left_num FROM lottery_single.t_prize;"
```

**查看用户抽奖次数：**
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "SELECT * FROM lottery_single.t_lottery_times;"
```

**查看已发放的优惠券：**
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "SELECT id, code, sys_status FROM lottery_single.t_coupon WHERE sys_status = 3 LIMIT 10;"
```
(sys_status = 3 表示已发放)

---

## PowerShell 测试脚本（Windows）

如果上面的测试脚本有编码问题，可以手动在 PowerShell 中执行：

```powershell
# 1. 登录
$loginResponse = Invoke-RestMethod -Uri "http://localhost:8081/admin/login" -Method Post -Body '{"user_name":"testuser","pass_word":"123456"}' -ContentType "application/json"
$token = $loginResponse.data.token
Write-Host "Token: $token" -ForegroundColor Green

# 2. 抽奖 10 次
for ($i = 1; $i -le 10; $i++) {
    $body = @{token=$token; user_id=1; ip="127.0.0.1"} | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "http://localhost:8081/lottery/v2/get_lucky" -Method Post -Body $body -ContentType "application/json"

    if ($result.code -eq 0) {
        Write-Host "第 $i 次: 中奖！$($result.data.title)" -ForegroundColor Green
    } else {
        Write-Host "第 $i 次: 未中奖" -ForegroundColor Yellow
    }
    Start-Sleep -Milliseconds 500
}
```

---

## 重置测试数据

如果需要重新测试，运行以下命令清空数据：

**Windows:**
```cmd
reset_and_test.bat
```

**Linux/Mac:**
```bash
bash reset_and_test.sh
```

或手动执行：
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "TRUNCATE TABLE lottery_single.t_result; TRUNCATE TABLE lottery_single.t_lottery_times; UPDATE lottery_single.t_prize SET left_num = prize_num WHERE prize_num > 0; UPDATE lottery_single.t_coupon SET sys_status = 1;"
```

---

## 奖品概率说明

根据 test_data.sql 中的配置：

| 奖品 | 概率 | prize_code 区间 | prize_num | prize_type |
|------|------|----------------|-----------|------------|
| 谢谢参与 | 50% | 0-4999 | -1 (不限量) | 0 |
| 10金币 | 30% | 5000-7999 | 0 (不限量) | 1 (虚拟币) |
| 50元优惠券 | 15% | 8000-9499 | 500 (限量) | 2 (虚拟券) |
| 蓝牙耳机 | 4% | 9500-9899 | 100 (限量) | 3 (实物小奖) |
| iPhone 16 Pro | 1% | 9900-9999 | 10 (限量) | 4 (实物大奖) |

**注意：**
- "谢谢参与"（prize_num = -1）不会记录到 t_result 表中
- 抽到"谢谢参与"时，返回 code = 100010，msg = "not won,please try again!"
- 只有实际中奖（金币、优惠券、实物）才会记录到数据库

---

## 测试验证清单

- [ ] 登录成功并获取 Token
- [ ] 抽奖接口能正常调用
- [ ] 能够中到不同类型的奖品（多抽几次）
- [ ] 中奖记录保存到数据库
- [ ] 奖品库存正确扣减
- [ ] 优惠券正确发放并标记为已使用
- [ ] 用户抽奖次数记录正确

---

## 常见问题

### Q: 为什么一直显示"未中奖"？

A: 有 50% 概率抽到"谢谢参与"，返回"未中奖"是正常的。多抽几次（10-20次）应该能中到虚拟币或优惠券。

### Q: 如何查看是否真的中奖了？

A: 查看数据库中的 t_result 表：
```bash
docker exec lottery_mysql mysql -uroot -p1234 -e "SELECT * FROM lottery_single.t_result ORDER BY id DESC LIMIT 10;"
```

### Q: Token 过期了怎么办？

A: 重新登录获取新的 Token。

---

## 成功测试示例

```bash
# 登录
$ curl -X POST http://localhost:8081/admin/login -H "Content-Type: application/json" -d '{"user_name":"testuser","pass_word":"123456"}'
{"code":0,"msg":"ok","data":{"user_id":1,"token":"eyJ..."}}

# 抽奖（替换 YOUR_TOKEN）
$ curl -X POST http://localhost:8081/lottery/v2/get_lucky -H "Content-Type: application/json" -d '{"token":"YOUR_TOKEN","user_id":1,"ip":"127.0.0.1"}'

# 结果1: 未中奖
{"code":100010,"msg":"not won,please try again!","data":null}

# 结果2: 中奖！
{"code":0,"msg":"ok","data":{"id":2,"title":"10金币",...}}
```

测试愉快！
