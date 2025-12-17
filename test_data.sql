-- 测试数据准备脚本
-- 使用方式：在 MySQL 容器中执行此脚本

USE lottery_single;

-- 1. 插入测试用户
-- testuser 密码: 123456
-- admin 密码: admin123
INSERT INTO `t_user` (`user_name`, `pass_word`, `signature`)
VALUES
('testuser', '$2a$10$NXItccG.7OLF6OMGSXJXk.5NZ1Ci9/CSSLZW2whXjTH8FtotQ4jOa', ''),
('admin', '$2a$10$cw/wdiQiOLyLSNbQv5vnZOBrGwtpkjnD7RE5YbE7CVgRN45IbqFna', '');

-- 2. 插入测试奖品（概率分配：谢谢参与 50%，虚拟币 30%，优惠券 15%，手机 4%，大奖 1%）
INSERT INTO `t_prize`
(`title`, `prize_num`, `left_num`, `prize_code`, `prize_time`, `img`, `display_order`, `prize_type`, `prize_profile`, `begin_time`, `end_time`, `sys_status`, `sys_created`, `sys_updated`, `sys_ip`)
VALUES
-- 谢谢参与 (50% 概率，prize_code: 0-4999)
('谢谢参与', -1, 0, '0-4999', 0, 'https://via.placeholder.com/100', 1, 0, '', '2025-01-01 00:00:00', '2026-12-31 23:59:59', 1, NOW(), NOW(), '127.0.0.1'),

-- 虚拟币 (30% 概率，prize_code: 5000-7999)
('10金币', 0, 0, '5000-7999', 0, 'https://via.placeholder.com/100', 2, 1, '{"coins": 10}', '2025-01-01 00:00:00', '2026-12-31 23:59:59', 1, NOW(), NOW(), '127.0.0.1'),

-- 优惠券 (15% 概率，prize_code: 8000-9499)
('50元优惠券', 500, 500, '8000-9499', 30, 'https://via.placeholder.com/100', 3, 2, '{"amount": 50}', '2025-01-01 00:00:00', '2026-12-31 23:59:59', 1, NOW(), NOW(), '127.0.0.1'),

-- 实物小奖 (4% 概率，prize_code: 9500-9899)
('蓝牙耳机', 100, 100, '9500-9899', 30, 'https://via.placeholder.com/100', 4, 3, '{"model": "AirPods"}', '2025-01-01 00:00:00', '2026-12-31 23:59:59', 1, NOW(), NOW(), '127.0.0.1'),

-- 实物大奖 (1% 概率，prize_code: 9900-9999)
('iPhone 16 Pro', 10, 10, '9900-9999', 30, 'https://via.placeholder.com/100', 5, 4, '{"model": "iPhone 16 Pro 256GB"}', '2025-01-01 00:00:00', '2026-12-31 23:59:59', 1, NOW(), NOW(), '127.0.0.1');

-- 3. 为优惠券奖品插入优惠券码（假设优惠券的 prize_id 是 3）
INSERT INTO `t_coupon` (`prize_id`, `code`, `sys_created`, `sys_updated`, `sys_status`)
SELECT 3, CONCAT('COUPON-', LPAD(n, 6, '0')), NOW(), NOW(), 1
FROM (
    SELECT @row := @row + 1 as n
    FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t3,
         (SELECT @row:=0) r
    LIMIT 500
) numbers;

-- 4. 验证数据
SELECT '===== 用户列表 =====' as '';
SELECT id, user_name FROM t_user;

SELECT '===== 奖品列表 =====' as '';
SELECT id, title, prize_num, left_num, prize_code, prize_type FROM t_prize WHERE sys_status = 1;

SELECT '===== 优惠券数量 =====' as '';
SELECT COUNT(*) as coupon_count FROM t_coupon WHERE sys_status = 1;
