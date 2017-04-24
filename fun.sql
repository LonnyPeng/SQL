CREATE DATABASE IF NOT EXISTS `t_dota` DEFAULT CHARSET utf8;
CREATE TABLE `t_product` (`product_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `product_name` VARCHAR(45) NOT NULL, `product_add_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `product_status` INT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_equip` (`equip_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `equip_name` VARCHAR(45) NOT NULL, `equip_note` VARCHAR(256), `equip_add_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `equip_modified_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `equip_status` INT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_equip_compound` (`equip_id` INT(11) NOT NULL, `product_id` INT(11) NOT NULL, `product_quantity` INT(3) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_employee` (`employee_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `employee_name` VARCHAR(45) NOT NULL, `employee_type_id` INT(11) NOT NULL, `employee_note` VARCHAR(256), `employee_add_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `employee_modified_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `employee_status` INT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_employee_type` (`employee_type_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `employee_type_name` VARCHAR(45) NOT NULL, `employee_type_status` INT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_employee_level` (`employee_level_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `employee_id` INT(11) NOT NULL, `employee_level_code` INT(3) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_employee_equip` (`employee_level_id` INT(11) NOT NULL, `equip_id` INT(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_book` (`book_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `book_name` VARCHAR(45) NOT NULL, `book_author` VARCHAR(50) NOT NULL, `book_note` TEXT, `book_content` LONGTEXT NOT NULL, `book_add_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `book_modified_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `book_status` INT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `t_leave_status` (`leave_status_id` INT(11) DEFAULT 0, `leave_status_name` VARCHAR(10) DEFAULT NULL COMMENT 'status name', `leave_is_valid` TINYINT(1) DEFAULT 1 COMMENT '0 - invalid; 1 - valid', PRIMARY KEY (`leave_status_id`)) ENGINE=MYISAM DEFAULT CHARSET=utf8;
INSERT INTO `t_leave_status` (`leave_status_id`, `leave_status_name`, `leave_is_valid`) VALUES (1, 'Draft', 1), (2, 'Pending', 1), (3, 'Approved', 1);
CREATE TABLE `t_statutory_holiday` (`statutory_holiday_id` INT(11) AUTO_INCREMENT, `statutory_holiday_name` VARCHAR(64) DEFAULT NULL COMMENT 'holiday name', `statutory_holiday_day` DATE DEFAULT NULL COMMENT 'holiday and working day', `statutory_holiday_year` INT(11) DEFAULT 0 COMMENT 'holidays of the year', `statutory_holiday_type` TINYINT(1) DEFAULT 1 COMMENT '0 - working day; 1 - holiday', `statutory_holiday_is_valid` TINYINT(1) DEFAULT 1 COMMENT '0 - invalid; 1 - valid', PRIMARY KEY (`statutory_holiday_id`)) ENGINE=MYISAM DEFAULT CHARSET=utf8;
ALTER TABLE `t_leave_type` ADD `type_permission` INT(11) DEFAULT 1 COMMENT 'show for 1 - everyone; 2 - only HR', ADD `type_limited_day` ENUM('workingday', 'calendarday', 'fullcalendarday') DEFAULT 'workingday' COMMENT 'limited day';
UPDATE `t_leave_type` SET `type_name` = 'Annual/Shift Leave' WHERE `type_id` = 1;
UPDATE `t_leave_type` SET `type_permission` = 2 WHERE `type_id` IN (9, 2, 14);
UPDATE `t_leave_type` SET `type_limited_day` = 'fullcalendarday' WHERE `type_id` IN (4, 5, 6, 7, 8);
UPDATE `t_leave_type` SET `type_limited_day` = 'calendarday' WHERE `type_id` = 11;
ALTER TABLE `t_leave` CHANGE `member_id` `emp_id` INT(11) DEFAULT 0 COMMENT 'employee id', MODIFY COLUMN leave_units float(5,2), ADD `leave_start_part` TINYINT(1) DEFAULT 1 COMMENT '0 - half day; 1 - full day' AFTER `leave_start_time`, ADD `leave_end_part` TINYINT(1) DEFAULT 1 COMMENT '0 - half day; 1 - full day' AFTER `leave_end_time`, ADD `approve_time` datetime default NULL AFTER submit_time, ADD `leave_status_id` INT(11) DEFAULT 0 COMMENT 'leave status', ADD `member_id` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'submit person', ADD `approve_member_id` smallint(5) UNSIGNED NOT NULL COMMENT 'approve person', ADD `relative` ENUM('direct', 'indirect') DEFAULT NULL COMMENT 'relative for compassionate leave', ADD `leave_state` varchar(256) default NULL DEFAULT NULL;
UPDATE t_leave SET leave_type_id = 1 WHERE leave_type_id = 12;
UPDATE t_leave SET leave_start_part = 0 WHERE (leave_units - FLOOR(leave_units)) = 0.5;
UPDATE t_leave SET leave_status_id = 3 WHERE is_draft = 0;
UPDATE t_leave SET leave_status_id = 2 WHERE is_draft = 1;
UPDATE t_leave SET approve_time = submit_time WHERE is_draft = 0;
UPDATE t_leave SET member_id = (SELECT member_id FROM t_member WHERE member_email = 'claudia.c@eyebuydirect.com');
UPDATE t_leave SET approve_member_id = member_id WHERE leave_status_id = 3;
ALTER TABLE t_shift MODIFY COLUMN shift_units float(5,2);
ALTER TABLE `t_employee_leave_state` MODIFY COLUMN leave_default_units float(5,2), MODIFY COLUMN leave_state_units float(5,2);
ALTER TABLE t_shift CHANGE `member_id` `emp_id` INT(11) DEFAULT 0 COMMENT 'employee id', ADD `shift_start_part` TINYINT(1) DEFAULT 1 COMMENT '0 - half day; 1 - full day' AFTER `shift_start_time`, ADD `shift_end_part` TINYINT(1) DEFAULT 1 COMMENT '0 - half day; 1 - full day' AFTER `shift_end_time`, ADD `approve_time` datetime DEFAULT NULL AFTER submit_time, ADD `leave_status_id` INT(11) DEFAULT 0 COMMENT 'leave status', ADD `member_id` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'submit person', ADD `approve_member_id` smallint(5) UNSIGNED NOT NULL COMMENT 'approve person', ADD `relative` ENUM('direct', 'indirect') DEFAULT NULL COMMENT 'relative for compassionate leave', ADD `shift_state` varchar(256) DEFAULT NULL;
UPDATE t_shift SET shift_start_part = 0 WHERE (shift_units - FLOOR(shift_units)) = 0.5;
UPDATE t_shift SET leave_status_id = 3 WHERE is_draft = 0;
UPDATE t_shift SET leave_status_id = 1 WHERE is_draft = 1;
UPDATE t_shift SET approve_time = submit_time WHERE is_draft = 0;
UPDATE t_shift SET member_id = (SELECT member_id FROM t_member WHERE member_email = 'claudia.c@eyebuydirect.com');
UPDATE t_shift SET approve_member_id = member_id WHERE leave_status_id = 3;
UPDATE t_leave SET submit_time = create_time WHERE submit_time = '0000-00-00 00:00:00';
UPDATE t_shift SET submit_time = create_time WHERE submit_time = '0000-00-00 00:00:00';
UPDATE t_member m, t_employee e SET m.emp_id = e.emp_id WHERE e.emp_email = m.member_email AND m.emp_id IN('', 0, null);
SELECT m.member_email, m.emp_id FROM t_member m, t_employee e WHERE e.emp_email = m.member_email AND m.emp_id IN('', 0, null);
ALTER TABLE t_member ADD `member_perms_addition` SET('case_forecast') DEFAULT "" AFTER `member_perms`;
UPDATE t_member SET member_perms_addition = 'case_forecast';
CREATE TABLE `t_cms_banner_gif` (`gif_id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `gif_file` VARCHAR(45) NOT NULL, `gif_left` FLOAT(3,2) NOT NULL, `gif_top` FLOAT(3,2) NOT NULL, `gif_status` INT(1) DEFAULT 1) ENGINE=MYISAM DEFAULT CHARSET=utf8;
ALTER TABLE `t_cms_banner` ADD `banner_large_gif_id` INT(11) DEFAULT 0 AFTER `banner_large_height`, ADD `banner_small_gif_id` INT(11) DEFAULT 0 AFTER `banner_small_height`;
ALTER TABLE `t_cms_banner` DROP COLUMN banner_large_gif_id, DROP COLUMN banner_small_gif_id;
DROP TABLE t_cms_banner_gif;
TRUNCATE t_cms_banner_gif;
CREATE TABLE `t_product_ins` (`ins_id` SMALLINT(5) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, `product_id` SMALLINT(5) UNSIGNED NOT NULL, `product_color` VARCHAR(45) NOT NULL, `model_id` SMALLINT(5) UNSIGNED NOT NULL, `ins_key` VARCHAR(20) NOT NULL, `ins_image_file` VARCHAR(45), `ins_add` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `ins_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `member_id` SMALLINT(5) UNSIGNED NOT NULL, `ins_status` TINYINT(1) DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE t_product_ins;
TRUNCATE t_product_ins;
USE ebd_main;
TRUNCATE t_maps;
USE ebd_hr;
ALTER TABLE t_shift CHANGE member_id emp_id int(11);
ALTER TABLE t_shift ADD member_id smallint(5) AFTER create_time;
ALTER TABLE t_shift ADD shift_start_part tinyint(1) DEFAULT 1 AFTER shift_start_time;
ALTER TABLE t_shift ADD shift_end_part tinyint(1) DEFAULT 1 AFTER shift_end_time;
ALTER TABLE t_shift ADD leave_status_id int(11) DEFAULT 3 AFTER is_draft;
UPDATE t_shift SET leave_status_id = 3 WHERE is_draft = 0;
UPDATE t_shift SET leave_status_id = 1 WHERE is_draft = 1;
UPDATE t_shift SET member_id = (SELECT member_id FROM t_member WHERE member_email = 'claudia.c@eyebuydirect.com') WHERE leave_status_id = 3;
ALTER TABLE t_album ADD file_path varchar(100) AFTER album_cover;
UPDATE t_recruitment SET recruitment_close_date = "" WHERE recruitment_status_id <> 4;
ALTER TABLE ebd_hr.t_leave DROP COLUMN is_draft;
UPDATE ebd_hr.t_employee_leave_state SET leave_state_units = 0 WHERE emp_id = 51;
UPDATE ebd_hr.t_employee_leave_state SET leave_default_units = 2, leave_state_units = 0 WHERE emp_id = 51 AND leave_type_id = 1 AND leave_state_year = 2015;
TRUNCATE TABLE t_statutory_holiday;
TRUNCATE TABLE t_employee_leave_state;
TRUNCATE TABLE t_leave;
TRUNCATE TABLE t_shift;
DELETE FROM ebd_hr.t_employee_leave_state WHERE emp_id = 78;
ALTER TABLE ebd_hr.t_leave ADD is_draft int(1) AFTER emp_id;
alter table test change t_name t_name_new varchar(20);
SELECT (SELECT t.type_name FROM t_leave_type t WHERE t.type_id = l.leave_type_id) AS 类型, l.leave_state_year as 年份, l.leave_default_units AS 默认值, l.leave_state_units AS 已使用值 FROM t_employee_leave_state l WHERE l.emp_id = (SELECT e.emp_id FROM t_employee e WHERE e.emp_english_name LIKE '%May Wu%');
UPDATE t_leave SET leave_state = '';
SELECT t.emp_id, t.leave_type_id, t.leave_state_year, (t.leave_default_units - t.leave_state_units) as units FROM t_employee_leave_state t WHERE (t.leave_default_units - t.leave_state_units) < 0;
UPDATE t_member SET member_hr_perms = 'hr_admin' WHERE member_firstname = 'lonny';
UPDATE t_member SET member_hr_perms = 'hr_employee_read' WHERE member_firstname = 'lonny';
UPDATE t_member SET member_hr_perms = 'hr_gm' WHERE member_firstname = 'lonny';
UPDATE t_leave SET submit_time = create_time WHERE submit_time = '0000-00-00 00:00:00';
UPDATE t_cms_social_media SET lang_locales = 'en_US,en_AU,en_CA,fr_CA,fr_FR,de_DE,en_GB';
ALTER TABLE t_product_ins ADD `ins_image_file` CHAR(50);
UPDATE t_member SET member_hr_perms = 'hr_employee_read' WHERE member_email = 'lonny.p@eyebuydirect.com';
UPDATE t_member SET member_hr_perms = 'hr_admin' WHERE member_email = 'lonny.p@eyebuydirect.com';
UPDATE t_member SET member_hr_perms = 'hr_proxy,hr_employee_read' WHERE member_email = 'lonny1.p@eyebuydirect.com';
ALTER TABLE t_member MODIFY COLUMN member_hr_perms SET('hr_report_read','hr_app_add','hr_app_read','hr_app_approve','hr_employee_read','hr_employee_add','hr_employee_part_edit','hr_admin','hr_gm', 'hr_proxy');
ALTER TABLE t_languages DROP column `as`;
DELETE FROM t_baike WHERE baike_content = 'fasle';
SELECT banner_id FROM t_cms_banner ORDER BY banner_id DESC LIMIT 1;
TRUNCATE t_product_ins;
DELETE FROM t_cms_banner WHERE banner_id > 4357;
source c:/test.sql;
ALTER TABLE `t_cms_advertise` ADD `ad_bg_color` VARCHAR(7) DEFAULT "" AFTER `ad_terms`;
SELECT s.create_time FROM t_shift s, t_employee e WHERE s.emp_id = e.emp_id AND e.emp_english_name LIKE '%Lonny%';
SELECT mg.* FROM t_member_log mg, t_member m, t_employee e WHERE mg.log_action = 'insert' AND mg.log_page = '/hr/attendance/shift-edit' AND mg.member_id = m.member_id AND  m.member_email= e.emp_email AND e.emp_english_name LIKE '%Jean%'\G;
ALTER TABLE `t_cms_advertise` CHANGE `ad_bg_color` `ad_desktop_bg_color` VARCHAR(7) DEFAULT "" AFTER `ad_terms`, ADD `ad_phone_bg_color` VARCHAR(7) DEFAULT "" AFTER `ad_desktop_bg_color`, ADD `ad_border_color` VARCHAR(7) DEFAULT "" AFTER `ad_phone_bg_color`;
ALTER TABLE `t_cms_advertise` CHANGE `ad_desktop_bg_color` `ad_bg_color` VARCHAR(7) DEFAULT "", CHANGE `ad_phone_bg_color` `ad_font_color` VARCHAR(7) DEFAULT "";
INSERT INTO t_cms_banner_type SET banner_type = 'other', banner_type_name = 'Other', banner_large_width = '0', banner_large_height = '0', banner_small_width = '0', banner_small_height = '0';
ALTER TABLE `t_cms_promotion_display` CHANGE `page_id` `page_id` VARCHAR(255);
ALTER TABLE `t_employee` ADD `emp_en_name_id` VARCHAR(64) DEFAULT "" AFTER `emp_english_name`;
ALTER TABLE `report_customers_bronto_basic` CHANGE `custom_refer_friend_count` `c_refer_friend_count` INT(11) NOT NULL;
SELECT c.customers_email_address, SUM(re.is_purchased) FROM t_referral_email re LEFT JOIN customers c ON c.customers_id = re.user_id WHERE is_purchased = 1 GROUP BY re.user_id;
SELECT c.customers_email_address, COUNT(re.referral_email_id) FROM t_referral_email re, customers c WHERE is_purchased = 1 AND c.customers_id = re.user_id GROUP BY re.user_id;
SELECT b.class_id FROM t_product_class b WHERE b.class_level = 2;
UPDATE t_product_class a SET a.class_level = 3 WHERE (a.parent_class_id >= 1118 AND a.parent_class_id <= 1571) OR (a.parent_class_id IN (10059, 10060, 10061));
SELECT a.class_name_zhcn AS 一级标题 FROM t_product_class a WHERE a.parent_class_id = 0 AND a.class_status = 1;
SELECT (SELECT c.class_name_zhcn FROM t_product_class c WHERE c.class_id = b.parent_class_id AND c.class_status = 1) AS 一级标题, b.class_name_zhcn AS 二级标题 FROM t_product_class b WHERE b.parent_class_id IN (SELECT a.class_id FROM t_product_class a WHERE a.parent_class_id = 0 AND a.class_status = 1) AND b.class_status = 1;
SELECT (SELECT a.class_name_zhcnFROM t_product_class a WHERE a.class_status = 1AND a.class_id IN (SELECT b.parent_class_id FROM t_product_class b WHERE b.class_status = 1AND b.class_id = c.parent_class_id)) AS 一级标题, (SELECT b.class_name_zhcn FROM t_product_class b WHERE b.class_status = 1AND b.class_id = c.parent_class_id) AS 二级标题, c.class_name_zhcn AS 三级标题 FROM t_product_class c WHERE c.class_status = 1 AND c.parent_class_id IN (SELECT b.class_id FROM t_product_class b WHERE b.class_status = 1 AND b.parent_class_id IN (SELECT a.class_id FROM t_product_class a WHERE a.class_status = 1 AND a.parent_class_id = 0));
SELECT e.employee_name, el.employee_level_code, p.product_name, SUM(ec.product_quantity)
FROM t_employee e LEFT JOIN t_employee_level el ON el.employee_id = e.employee_id LEFT JOIN t_employee_equip ee ON ee.employee_level_id = el.employee_level_id LEFT JOIN t_equip ea ON ea.equip_id = ee.equip_id LEFT JOIN t_equip_compound ec ON ec.equip_id = ea.equip_id LEFT JOIN t_product p ON p.product_id = ec.product_id WHERE e.employee_status = 1 AND e.employee_name = '船长' GROUP BY e.employee_id, el.employee_level_id, p.product_id;
SELECT Isnull(Count(*),0) AS BoxQty, Isnull(Sum(Qty),0) AS Qty FROM recMainStorageIO WHERE VoucClassID=119 and VoucSubjectID=1145 and BoxCode IN (SELECT BoxCode FROM recMainStorageIO WHERE GoodsFamilyID = 1027) GROUP BY BoxCode HAVING(SUM(CASE VoucClassID WHEN 119 THEN 1 WHEN 120 THEN -1 ELSE 0 END)>0));
SELECT mv.box_code, mv.item_id, IFNULL(SUM(CASE mv.voucher_class WHEN 'in' THEN mv.voucher_quantity WHEN 'out' THEN 0 - mv.voucher_quantity ELSE 0 END), 0) AS quantity FROM t_mstock_voucher mv LEFT JOIN t_product p ON p.product_id = mv.item_id AND product_status = 1 RIGHT JOIN t_mstock_voucher mva ON mva.item_id = mv.item_id AND mva.voucher_disabled = 0 AND mva.item_class = 'frame' AND mva.subject_id = 1 AND mva.box_code IN (SELECT mvb.box_code FROM t_mstock_voucher mvb LEFT JOIN t_product mvbp ON mvbp.product_id = mvb.item_id WHERE mvb.voucher_disabled = 0 AND mvb.item_class = 'frame' AND mvbp.class_id = p.class_id GROUP BY mvb.box_code HAVING (SUM(CASE mvb.voucher_class WHEN 'in' THEN 1 WHEN 'out' THEN -1 ELSE 0 END) > 0)) LEFT JOIN t_product_class pc ON pc.class_id = p.class_id WHERE mv.voucher_disabled = 0 AND mv.item_class = 'frame' AND mv.subject_id = 1 AND p.product_code LIKE '%PM0314%' GROUP BY mv.item_id
SELECT Max(a.StockTakeID) AS StockTakeID,Max(a.OprDate) AS OprDate ,Isnull(Sum(a.StockQty),0) AS StockQty,Isnull(Sum(a.StockTakeQty),0) AS StockTakeQty,Max(b.GoodsCode) AS GoodsCode,Max(b.GoodsName) AS GoodsName,Max(b.GoodsSpec) AS GoodsSpec ,Max(c.DictNameEN) AS GoodsFamilyEN,Max(c.DictNameCN) AS GoodsFamilyCN FROM recMainStorageST AS a LEFT JOIN bscStockGoods AS b ON a.GoodsID=b.GoodsID LEFT JOIN bscDictionary AS c ON a.GoodsFamilyID=c.DictID WHERE a.StockTakeID=132 GROUP BY b.GoodsID ORDER BY Max(b.GoodsName),Max(b.GoodsSpec),Max(b.GoodsCode)
INSERT INTO recMainStorageST (StockTakeID,GoodsMainClassID,GoodsFamilyID,GoodsID,BoxCode,StockQty,StockTakeStatusID,UserID,OprDate) 
SELECT NewStockTakeID, QueryGoodsMainClassID, createGoodsFamilyID, GoodsID,BoxCode,Qty,1378, UserID, date() FROM recMainStorageIO WHERE VoucClassID=119 and VoucSubjectID=1145 and BoxCode IN (SELECT BoxCode FROM recMainStorageIO WHERE GoodsFamilyID = createGoodsFamilyID GROUP BY BoxCode HAVING(SUM(CASE VoucClassID WHEN 119 THEN 1 WHEN 120 THEN -1 ELSE 0 END)>0)));
INSERT INTO t_mstock_stats (counting_id, item_class, item_id, product_class_id, subject_id, box_code, stock_quantity, stats_quantity, stats_time, stats_status, employee_id) 
SELECT (CASE (SELECT counting_id FROM t_mstock_stats ORDER BY counting_id DESC LIMIT 1) AS counting_id WHEN NULL THEN 100 ELSE (counting_id + 1) END), 'frame', item_id, create_class_id, subject_id, box_code, stock_quantity, 0, now(), 'counting', login_id FROM t_mstock_voucher WHERE voucher_disabled = 0 AND item_class = 'frame' AND product_class_id = create_class_id GROUP BY box_code HAVING (SUM(CASE voucher_class WHEN 'in' THEN 1 WHEN 'out' THEN -1 ELSE 0 END) > 0);
ALTER TABLE `t_toponymy` ADD `toponymy_order` VARCHAR(225) DEFAULT "" AFTER `toponymy_parent_id`;
ALTER TABLE t_toponymy CHANGE toponymy_name toponymy_name VARCHAR(200) NOT NULL,
CHANGE toponymy_order toponymy_order VARCHAR(225) NOT NULL UNIQUE KEY;
ALTER TABLE t_toponymy MODIFY COLUMN toponymy_name VARCHAR(200) NOT NULL;
update t_toponymy SET toponymy_order = '';
DELETE FROM t_toponymy WHERE toponymy_id > 3763;