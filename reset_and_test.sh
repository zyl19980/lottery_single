#!/bin/bash

# Linux/Mac 快速重置和测试脚本
# 使用方式: bash reset_and_test.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "重置数据库并运行测试"
echo "======================================"
echo ""

echo -e "${YELLOW}[步骤 1/3] 清空现有数据...${NC}"
docker exec -i lottery_mysql mysql -uroot -p1234 -e "USE lottery_single; TRUNCATE TABLE t_user; TRUNCATE TABLE t_prize; TRUNCATE TABLE t_coupon; TRUNCATE TABLE t_result; TRUNCATE TABLE t_lottery_times; TRUNCATE TABLE t_black_user; TRUNCATE TABLE t_black_ip;"
if [ $? -ne 0 ]; then
    echo "清空数据失败！"
    exit 1
fi
echo -e "${GREEN}清空数据完成！${NC}"
echo ""

echo -e "${YELLOW}[步骤 2/3] 导入测试数据...${NC}"
docker exec -i lottery_mysql mysql -uroot -p1234 lottery_single < test_data.sql
if [ $? -ne 0 ]; then
    echo "导入测试数据失败！"
    exit 1
fi
echo -e "${GREEN}导入测试数据完成！${NC}"
echo ""

echo -e "${YELLOW}[步骤 3/3] 验证数据...${NC}"
docker exec -it lottery_mysql mysql -uroot -p1234 -e "USE lottery_single; SELECT '===== 用户列表 =====' as ''; SELECT id, user_name FROM t_user; SELECT '===== 奖品列表 =====' as ''; SELECT id, title, prize_num, left_num, prize_code FROM t_prize WHERE sys_status = 1;"
echo ""

echo "======================================"
echo -e "${GREEN}数据准备完成！现在可以运行测试了${NC}"
echo "======================================"
echo ""
echo "运行测试："
echo "  bash test_api.sh"
echo ""
