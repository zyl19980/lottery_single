#!/bin/bash

# 抽奖系统接口测试脚本
# 使用方式：bash test_api.sh

BASE_URL="http://localhost:8081"
TOKEN=""

echo "======================================"
echo "抽奖系统接口测试"
echo "======================================"
echo ""

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试 1: 用户登录
echo -e "${YELLOW}[测试 1] 用户登录${NC}"
echo "请求: POST $BASE_URL/admin/login"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"user_name":"testuser","pass_word":"123456"}')

echo "响应: $LOGIN_RESPONSE"

# 提取 token (假设返回格式是 {"code":200,"data":{"token":"xxx"}})
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$TOKEN" ]; then
  echo -e "${RED}登录失败！请检查用户名和密码${NC}"
  echo "提示：默认用户名 testuser，密码 123456"
  exit 1
else
  echo -e "${GREEN}登录成功！Token: $TOKEN${NC}"
fi
echo ""

# 测试 2: 获取奖品列表
echo -e "${YELLOW}[测试 2] 获取奖品列表${NC}"
echo "请求: GET $BASE_URL/admin/get_prize_list"
PRIZE_LIST=$(curl -s -X GET "$BASE_URL/admin/get_prize_list")
echo "响应: $PRIZE_LIST"
echo ""

# 测试 3: 抽奖（执行 10 次）
echo -e "${YELLOW}[测试 3] 执行抽奖（10次）${NC}"
for i in {1..10}
do
  echo "第 $i 次抽奖..."
  LOTTERY_RESPONSE=$(curl -s -X POST "$BASE_URL/lottery/v2/get_lucky" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$TOKEN\",\"user_id\":1,\"ip\":\"127.0.0.1\"}")

  # 提取奖品名称
  PRIZE_NAME=$(echo $LOTTERY_RESPONSE | grep -o '"prize_name":"[^"]*' | sed 's/"prize_name":"//')

  if [ ! -z "$PRIZE_NAME" ]; then
    echo -e "  ${GREEN}中奖: $PRIZE_NAME${NC}"
  else
    echo "  响应: $LOTTERY_RESPONSE"
  fi

  # 延迟 0.5 秒，避免请求过快
  sleep 0.5
done
echo ""

# 测试 4: 快速抽奖测试（测试分布式锁）
echo -e "${YELLOW}[测试 4] 快速连续抽奖（测试并发控制）${NC}"
echo "连续发送 5 次请求，不等待..."
for i in {1..5}
do
  curl -s -X POST "$BASE_URL/lottery/v2/get_lucky" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$TOKEN\",\"user_id\":1,\"ip\":\"127.0.0.1\"}" &
done
wait
echo ""

# 测试 5: 测试无效 token
echo -e "${YELLOW}[测试 5] 使用无效 Token 抽奖${NC}"
INVALID_RESPONSE=$(curl -s -X POST "$BASE_URL/lottery/v2/get_lucky" \
  -H "Content-Type: application/json" \
  -d '{"token":"invalid_token","user_id":1,"ip":"127.0.0.1"}')
echo "响应: $INVALID_RESPONSE"
echo ""

# 测试 6: V1 版本抽奖接口
echo -e "${YELLOW}[测试 6] V1 版本抽奖接口${NC}"
V1_RESPONSE=$(curl -s -X POST "$BASE_URL/lottery/v1/get_lucky" \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"$TOKEN\",\"user_id\":1,\"ip\":\"127.0.0.1\"}")
echo "响应: $V1_RESPONSE"
echo ""

echo "======================================"
echo -e "${GREEN}测试完成！${NC}"
echo "======================================"
echo ""
echo "下一步操作："
echo "1. 查看数据库中的中奖记录："
echo "   docker exec -it lottery_mysql mysql -uroot -p1234 -e 'SELECT * FROM lottery_single.t_result ORDER BY id DESC LIMIT 20;'"
echo ""
echo "2. 查看用户抽奖次数："
echo "   docker exec -it lottery_mysql mysql -uroot -p1234 -e 'SELECT * FROM lottery_single.t_lottery_times;'"
echo ""
echo "3. 查看奖品剩余数量："
echo "   docker exec -it lottery_mysql mysql -uroot -p1234 -e 'SELECT id, title, prize_num, left_num FROM lottery_single.t_prize;'"
