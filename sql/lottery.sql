use lottery_system;

DROP TABLE IF EXISTS `t_prize`;
CREATE TABLE `t_prize`
(
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `title` varchar(255) NOT NULL DEFAULT '' COMMENT '奖品名称',
    `prize_num` int(11) NOT NULL DEFAULT '-1' COMMENT '奖品数量，0 无限量，>0限量，<0无奖品',
    `left_num` int(11) NOT NULL DEFAULT '0' COMMENT '剩余数量',
    `prize_code` varchar(50) NOT NULL DEFAULT '' COMMENT '0-9999表示100%，0-0表示万分之一的中奖概率',
    `prize_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发奖周期，多少天，以天为单位',
    `img` varchar(255) NOT NULL DEFAULT '' COMMENT '奖品图片',
    `display_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '位置序号，小的排在前面',
    `prize_type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '奖品类型，1-虚拟币，2-虚拟券，3-实物小奖，4-实物大奖',
    `prize_profile` varchar(255) NOT NULL DEFAULT '' COMMENT '奖品扩展数据，如：虚拟币数量',
    `begin_time` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '奖品有效周期：开始时间',
    `end_time` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '奖品有效周期：结束时间',
    `prize_plan` mediumtext COMMENT '发奖计划，[[时间1,数量1],[时间2,数量2]]',
    `prize_begin` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '发奖计划周期的开始',
    `prize_end` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' '发奖计划周期的结束',
    `sys_status` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT '状态，1-正常，2-删除',
    `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
    `sys_updated` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT'修改时间',
    `sys_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作人IP',
    PRIMARY KEY (`id`)
)ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='奖品表';


DROP TABLE IF EXISTS `t_coupon`;
CREATE TABLE `t_coupon` (
                            `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                            `prize_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '奖品ID，关联lt_prize表',
                            `code` varchar(255) NOT NULL DEFAULT '' COMMENT '虚拟券编码',
                            `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
                            `sys_updated` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '更新时间',
                            `sys_status` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT '状态，1-正常，2-作废，3-已发放',
                            PRIMARY KEY (`id`),
                            UNIQUE KEY `uk_code` (`code`),
                            KEY `idx_prize_id` (`prize_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='优惠券表';


DROP TABLE IF EXISTS `t_result`;
CREATE TABLE `t_result` (
                            `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                            `prize_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '奖品ID，关联lt_prize表',
                            `prize_name` varchar(255) NOT NULL DEFAULT '' COMMENT '奖品名称',
                            `prize_type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '奖品类型，同lt_prize. gtype',
                            `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
                            `user_name` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
                            `prize_code` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '抽奖编号（4位的随机数）',
                            `prize_data` varchar(255) NOT NULL DEFAULT '' COMMENT '获奖信息',
                            `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
                            `sys_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '用户抽奖的IP',
                            `sys_status` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT '状态，1-正常，2-删除，3-作弊',
                            PRIMARY KEY (`id`),
                            KEY `idx_user_id` (`user_id`),
                            KEY `idx_prize_id` (`prize_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='抽奖记录表';


DROP TABLE IF EXISTS `t_black_user`;
CREATE TABLE `t_black_user` (
                                `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                                `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
                                `user_name` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
                                `black_time` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '黑名单限制到期时间',
                                `real_name` varchar(50) NOT NULL DEFAULT '' COMMENT '真是姓名',
                                `mobile` varchar(50) NOT NULL DEFAULT '' COMMENT '手机号',
                                `address` varchar(255) NOT NULL DEFAULT '' COMMENT '联系地址',
                                `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
                                `sys_updated` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '修改时间',
                                `sys_ip` varchar(50) NOT NULL DEFAULT '' COMMENT 'IP地址',
                                PRIMARY KEY (`id`),
                                KEY `idx_user_name` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='用户黑明单表';


DROP TABLE IF EXISTS `t_black_ip`;
CREATE TABLE `t_black_ip` (
                              `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                              `ip` varchar(50) NOT NULL DEFAULT '' COMMENT 'IP地址',
                              `black_time` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '黑名单限制到期时间',
                              `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
                              `sys_updated` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '修改时间',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `uk_ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 comment='ip黑明单表';


DROP TABLE IF EXISTS `t_lottery_times`;
CREATE TABLE `t_lottery_times` (
                                   `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                                   `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
                                   `day` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '日期，如：20220625',
                                   `num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '次数',
                                   `sys_created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '创建时间',
                                   `sys_updated` datetime NOT NULL DEFAULT '1000-01-01 00:00:00' COMMENT '修改时间',
                                   PRIMARY KEY (`id`),
                                   UNIQUE KEY `idx_user_id_day` (`user_id`,`day`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 comment='用户每日抽奖次数表';


DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
                                   `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                                   `user_name` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
                                   `pass_word` varchar(255) NOT NULL DEFAULT '' COMMENT '用户密码',
                                   `signature`  varchar(255) NOT NULL DEFAULT '' COMMENT '登录用户签名',
                                   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 comment='用户表';


INSERT INTO `t_prize`
VALUES (1, 'T恤', 100, 90, '1-100', 30, 'https://p0.ssl.qhmsg.com/t016c44d161c478cfe0.png', 1, 3, '', 1532592420,
        1564128420,
        '[[1559360281,3],[1559446681,3],[1559538061,3],[1559601061,3],[1559657101,3],[1559743501,3],[1559829781,3],[1559970061,3],[1560001081,2],[1560002701,1],[1560136561,3],[1560224281,3],[1560292261,3],[1560397081,3],[1560483481,3],[1560520981,3],[1560656281,3],[1560741361,3],[1560780181,2],[1560780961,1],[1560897061,3],[1560983461,3],[1561088281,3],[1561125901,3],[1561261081,3],[1561347481,1],[1561348981,2],[1561431421,3],[1561471501,9],[1561500301,4],[1561539421,3],[1561625821,3],[1561778161,3],[1561817101,3]]',
        1559291761, 1561883761, 0, 1532592429, 1559291761, '::1'),
       (2, '360手机N8', 10, 9, '0-0', 30, 'https://p0.ssl.qhmsg.com/t016ff98b934914aca6.png', 0, 4, '', 1532592420,
        1564128420, '[[1559820493,10]]', 1559310793, 1561902793, 0, 1532592474, 1559310793, ''),
       (3, '手机充电器', 100, 87, '200-1000', 30, 'https://p0.ssl.qhmsg.com/t01ec4648d396ad46bf.png', 3, 3, '',
        1532592420, 1564128420,
        '[[1559441116,3],[1559549716,3],[1559636116,3],[1559653336,3],[1559738536,1],[1559740516,2],[1559894716,4],[1559895316,9],[1559911336,3],[1560045916,3],[1560154516,3],[1560218716,3],[1560256936,3],[1560343336,3],[1560500116,3],[1560564136,3],[1560650716,3],[1560690136,3],[1560823516,3],[1560909916,3],[1560996316,3],[1561035736,3],[1561122136,3],[1561277716,3],[1561341916,3],[1561381336,3],[1561514716,3],[1561601116,3],[1561709716,3],[1561773916,3],[1561882516,3]]',
        1559291776, 1561883776, 0, 1532592558, 1559291776, '::1'),
       (4, '优惠券', 1000, 894, '2000-5000', 1, 'https://p0.ssl.qhmsg.com/t01f84f00d294279957.png', 4, 2, '',
        1532592420, 1564128420,
        '[[1559316564,11],[1559320044,6],[1559320164,5],[1559320584,1],[1559320644,1],[1559320704,1],[1559320764,1],[1559320824,1],[1559320884,1],[1559320944,1],[1559321004,1],[1559321064,1],[1559321124,1],[1559321184,1],[1559321244,1],[1559321304,1],[1559321364,1],[1559321424,1],[1559321484,1],[1559321544,1],[1559321604,1],[1559321664,1],[1559321724,1],[1559321784,1],[1559321844,1],[1559321904,1],[1559321964,1],[1559322024,1],[1559322084,1],[1559322144,1],[1559322204,1],[1559322264,1],[1559322324,1],[1559322384,1],[1559322444,1],[1559322504,17],[1559322564,1],[1559322624,1],[1559322684,1],[1559322744,1],[1559322804,1],[1559322864,1],[1559322924,1],[1559322984,1],[1559323044,1],[1559323104,1],[1559323164,1],[1559323224,21],[1559323284,1],[1559323344,1],[1559323404,1],[1559323464,1],[1559323524,1],[1559323584,1],[1559323644,1],[1559323704,1],[1559323764,1],[1559323824,1],[1559323884,1],[1559323944,1],[1559324004,1],[1559324064,1],[1559324124,1],[1559324184,1],[1559324244,1],[1559324304,1],[1559324364,1],[1559324424,1],[1559324484,1],[1559324544,1],[1559324604,1],[1559324664,1],[1559324724,1],[1559324784,1],[1559324844,1],[1559324904,1],[1559324964,1],[1559325024,1],[1559325084,1],[1559325144,1],[1559325204,1],[1559325264,1],[1559325324,1],[1559325384,1],[1559325444,1],[1559325504,1],[1559325564,1],[1559325624,1],[1559325684,1],[1559325744,1],[1559325804,1],[1559325864,1],[1559325924,1],[1559325984,1],[1559326044,1],[1559326104,40],[1559326164,1],[1559326224,1],[1559326284,1],[1559326344,1],[1559326404,1],[1559326464,1],[1559326524,1],[1559326584,1],[1559326644,1],[1559326704,1],[1559326764,1],[1559326824,1],[1559326884,1],[1559326944,12],[1559327004,1],[1559327064,1],[1559327124,1],[1559327184,1],[1559327244,1],[1559327304,1],[1559327364,1],[1559327424,1],[1559327484,1],[1559327544,1],[1559327604,1],[1559327664,1],[1559327724,1],[1559330544,28],[1559331384,1],[1559331444,1],[1559331504,1],[1559331564,1],[1559331624,1],[1559331684,1],[1559331744,1],[1559331804,1],[1559331864,1],[1559331924,1],[1559331984,1],[1559332044,1],[1559332104,1],[1559332164,1],[1559332224,1],[1559332284,1],[1559332344,1],[1559332404,1],[1559332464,1],[1559332524,1],[1559332584,1],[1559332644,1],[1559332704,1],[1559332764,1],[1559332824,1],[1559332884,1],[1559332944,1],[1559333004,1],[1559333064,1],[1559333124,1],[1559333184,1],[1559333244,1],[1559333304,1],[1559333364,1],[1559333424,1],[1559333484,1],[1559333544,1],[1559333604,1],[1559333664,1],[1559333724,1],[1559333784,1],[1559333844,1],[1559333904,1],[1559333964,1],[1559334024,1],[1559334084,1],[1559334144,37],[1559334204,1],[1559334264,1],[1559334324,1],[1559334384,1],[1559334444,1],[1559334504,1],[1559334564,1],[1559334624,1],[1559334684,1],[1559334744,1],[1559334804,1],[1559334864,1],[1559334924,1],[1559337744,26],[1559339724,20],[1559341344,5],[1559343324,25],[1559346624,12],[1559346924,12],[1559350224,23],[1559353824,35],[1559354244,18],[1559357844,49],[1559360964,9],[1559361444,10],[1559364564,48],[1559365464,4],[1559369064,18],[1559372664,18],[1559374584,1],[1559374644,1],[1559374704,1],[1559374764,1],[1559374824,1],[1559374884,1],[1559374944,1],[1559375004,1],[1559375064,1],[1559375124,1],[1559375184,1],[1559375244,1],[1559375304,1],[1559375364,1],[1559375424,1],[1559375484,1],[1559375544,1],[1559375604,1],[1559375664,1],[1559375724,1],[1559375784,1],[1559375844,1],[1559375904,1],[1559375964,1],[1559376024,1],[1559376084,1],[1559376144,1],[1559376204,1],[1559376264,7],[1559376324,1],[1559376384,1],[1559376444,1],[1559376504,1],[1559376564,1],[1559376624,1],[1559376684,1],[1559376744,1],[1559376804,1],[1559376864,1],[1559376924,1],[1559376984,1],[1559377044,1],[1559377104,1],[1559377164,1],[1559377224,1],[1559377284,1],[1559377344,1],[1559377404,1],[1559377464,1],[1559377524,45],[1559377584,1],[1559377644,1],[1559377704,1],[1559377764,1],[1559377824,1],[1559377884,1],[1559377944,1],[1559378004,1],[1559378064,1],[1559378124,1]]',
        1559291784, 1559378184, 0, 1532599140, 1559291784, '::1');