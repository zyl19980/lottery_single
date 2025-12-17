@echo off
REM Windows 快速重置和测试脚本
REM 使用方式: reset_and_test.bat

echo ======================================
echo 重置数据库并运行测试
echo ======================================
echo.

echo [步骤 1/3] 清空现有数据...
docker exec -i lottery_mysql mysql -uroot -p1234 -e "USE lottery_single; TRUNCATE TABLE t_user; TRUNCATE TABLE t_prize; TRUNCATE TABLE t_coupon; TRUNCATE TABLE t_result; TRUNCATE TABLE t_lottery_times; TRUNCATE TABLE t_black_user; TRUNCATE TABLE t_black_ip;"
if errorlevel 1 (
    echo 清空数据失败！
    exit /b 1
)
echo 清空数据完成！
echo.

echo [步骤 2/3] 导入测试数据...
docker exec -i lottery_mysql mysql -uroot -p1234 lottery_single < test_data.sql
if errorlevel 1 (
    echo 导入测试数据失败！
    exit /b 1
)
echo 导入测试数据完成！
echo.

echo [步骤 3/3] 验证数据...
docker exec -it lottery_mysql mysql -uroot -p1234 -e "USE lottery_single; SELECT '===== 用户列表 =====' as ''; SELECT id, user_name FROM t_user; SELECT '===== 奖品列表 =====' as ''; SELECT id, title, prize_num, left_num, prize_code FROM t_prize WHERE sys_status = 1;"
echo.

echo ======================================
echo 数据准备完成！现在可以运行测试了
echo ======================================
echo.
echo 运行测试：
echo   powershell -ExecutionPolicy Bypass -File test_api.ps1
echo.

pause
