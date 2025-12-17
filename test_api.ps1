# 抽奖系统接口测试脚本 (Windows PowerShell)
# 使用方式：powershell -ExecutionPolicy Bypass -File test_api.ps1

$BASE_URL = "http://localhost:8081"
$TOKEN = ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "抽奖系统接口测试" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 测试 1: 用户登录
Write-Host "[测试 1] 用户登录" -ForegroundColor Yellow
Write-Host "请求: POST $BASE_URL/admin/login"

$loginBody = @{
    user_name = "testuser"
    pass_word = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/admin/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "响应: $($loginResponse | ConvertTo-Json -Depth 10)"

    if ($loginResponse.data.token) {
        $TOKEN = $loginResponse.data.token
        Write-Host "登录成功！Token: $TOKEN" -ForegroundColor Green
    } else {
        Write-Host "登录失败！请检查用户名和密码" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "登录请求失败: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 测试 2: 获取奖品列表
Write-Host "[测试 2] 获取奖品列表" -ForegroundColor Yellow
Write-Host "请求: GET $BASE_URL/admin/get_prize_list"

try {
    $prizeList = Invoke-RestMethod -Uri "$BASE_URL/admin/get_prize_list" -Method Get
    Write-Host "响应: $($prizeList | ConvertTo-Json -Depth 10)"
} catch {
    Write-Host "获取奖品列表失败: $_" -ForegroundColor Red
}
Write-Host ""

# 测试 3: 抽奖（执行 10 次）
Write-Host "[测试 3] 执行抽奖（10次）" -ForegroundColor Yellow

for ($i = 1; $i -le 10; $i++) {
    Write-Host "第 $i 次抽奖..."

    $lotteryBody = @{
        token = $TOKEN
        user_id = 1
        ip = "127.0.0.1"
    } | ConvertTo-Json

    try {
        $lotteryResponse = Invoke-RestMethod -Uri "$BASE_URL/lottery/v2/get_lucky" -Method Post -Body $lotteryBody -ContentType "application/json"

        if ($lotteryResponse.data.prize_name) {
            Write-Host "  中奖: $($lotteryResponse.data.prize_name)" -ForegroundColor Green
        } else {
            Write-Host "  响应: $($lotteryResponse | ConvertTo-Json -Depth 10)"
        }
    } catch {
        Write-Host "  抽奖请求失败: $_" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 500
}
Write-Host ""

# 测试 4: 快速抽奖测试（测试分布式锁）
Write-Host "[测试 4] 快速连续抽奖（测试并发控制）" -ForegroundColor Yellow
Write-Host "连续发送 5 次请求，不等待..."

$jobs = @()
for ($i = 1; $i -le 5; $i++) {
    $lotteryBody = @{
        token = $TOKEN
        user_id = 1
        ip = "127.0.0.1"
    } | ConvertTo-Json

    $jobs += Start-Job -ScriptBlock {
        param($url, $body)
        Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    } -ArgumentList "$BASE_URL/lottery/v2/get_lucky", $lotteryBody
}

$jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
Write-Host ""

# 测试 5: 测试无效 token
Write-Host "[测试 5] 使用无效 Token 抽奖" -ForegroundColor Yellow

$invalidBody = @{
    token = "invalid_token"
    user_id = 1
    ip = "127.0.0.1"
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "$BASE_URL/lottery/v2/get_lucky" -Method Post -Body $invalidBody -ContentType "application/json"
    Write-Host "响应: $($invalidResponse | ConvertTo-Json -Depth 10)"
} catch {
    Write-Host "预期的错误: $_" -ForegroundColor Yellow
}
Write-Host ""

# 测试 6: V1 版本抽奖接口
Write-Host "[测试 6] V1 版本抽奖接口" -ForegroundColor Yellow

$v1Body = @{
    token = $TOKEN
    user_id = 1
    ip = "127.0.0.1"
} | ConvertTo-Json

try {
    $v1Response = Invoke-RestMethod -Uri "$BASE_URL/lottery/v1/get_lucky" -Method Post -Body $v1Body -ContentType "application/json"
    Write-Host "响应: $($v1Response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Host "V1 接口请求失败: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "测试完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步操作："
Write-Host "1. 查看数据库中的中奖记录："
Write-Host '   docker exec -it lottery_mysql mysql -uroot -p1234 -e "SELECT * FROM lottery_single.t_result ORDER BY id DESC LIMIT 20;"'
Write-Host ""
Write-Host "2. 查看用户抽奖次数："
Write-Host '   docker exec -it lottery_mysql mysql -uroot -p1234 -e "SELECT * FROM lottery_single.t_lottery_times;"'
Write-Host ""
Write-Host "3. 查看奖品剩余数量："
Write-Host '   docker exec -it lottery_mysql mysql -uroot -p1234 -e "SELECT id, title, prize_num, left_num FROM lottery_single.t_prize;"'
