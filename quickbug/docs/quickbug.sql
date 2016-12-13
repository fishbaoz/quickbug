-- quickbug 缺陷库管理系统
-- 作者：V哥
-- Ver：1.0
-- 注意：导入这个SQL要有ROOT权限
-- 命令: mysql -uroot -proot < quickbug.sql

-- 建立库
-- drop database if exists `quickbug`;
-- create database if not exists `quickbug` default character set utf8;

-- 对应的用户
-- delete from mysql.user where user='quickbug';
-- grant all privileges on quickbug.* to 'quickbug'@'localhost' identified by 'quickbug123456' with grant option;
-- flush privileges;

-- 使用库
-- use `quickbug`;
set names utf8;

-- ---------------------------------------------------------------------------------------------------
-- 用户表
create table if not exists `quickbug_user` (
  `userid` int(11) not null auto_increment comment '用户id',
  `username` varchar(100) default '' comment '用户名',
  `truename` varchar(100) default '' comment '真实姓名-默认情况下和用户名相同',
  `passwd`  varchar(100) default '' comment 'md5-密码',
  `email` varchar(100) default '' comment 'EMAIL',
  `usertype` tinyint(4) default 1 comment '帐号类型: 1:自定义 2:RTX的帐号(可以自动登录)',
  `priv` tinyint(4) default 1 comment '用户权限: 1:普通用户 2:项目管理员 3:超级管理员',
  `enable` tinyint(4) default 1 comment '帐号是否启用: 1:启用 0:禁用',
  `dateline` int(11) default 0 comment '时间',
  `ext` text default '' comment '扩展字段信息',
  primary key (`userid`)
) engine=myisam default charset=utf8 comment='用户表';


-- 用户组(角色)
create table if not exists `quickbug_group` (
  `groupid` int(11) not null auto_increment comment '用户组id',
  `groupname` varchar(100) default '' comment '用户组名',
  `info` varchar(100) default '' comment '备注',
  `createuid` int(11) default 0 comment '创建者用户ID',
  `grouptype` tinyint(4) default '0' comment '用户组类型',
  `dateline` int(11) default 0 comment '时间',
  primary key (`groupid`)
) engine=myisam default charset=utf8 comment='用户组';

-- 用户组与用户关系(多对多的关系)
create table if not exists `quickbug_groupuser` (
  `guid` int(11) not null auto_increment comment '主键ID',
  `groupid` int(11) default 0 comment '用户组id',
  `userid` int(11) default 0 comment '用户id',
  primary key (`guid`),
  index (`groupid`),
  index (`groupid`,userid)
) engine=myisam default charset=utf8 comment='用户组与用户关系';

-- 用户组权限表
create table if not exists `quickbug_grouppriv` (
  `gpid` int(11) not null auto_increment comment '主键ID',
  `groupid` int(11) default 0 comment '用户组id',
  `priv` text comment '权限配置的序列化,如 array("1|2","2|1") 具体请看 Privconfig.php',
  primary key (`gpid`),
  unique index (`groupid`)
) engine=myisam default charset=utf8 comment='用户组权限表';

-- ---------------------------------------------------------------------------------------------------

-- 项目
create table if not exists `quickbug_project` (
  `projectid` int(11) not null auto_increment comment '主键id',
  `projectname` varchar(100) default '' comment '项目名',
  `info` text comment '备注',
  `userid` int(11) default 0 comment '用户id,谁创建的',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`projectid`),
  key `userid` (`userid`)
) engine=myisam default charset=utf8 comment='项目';

-- 项目的文档(如需求，效果图等)
create table if not exists `quickbug_project_docs` (
  `pjdocid` int(11) not null auto_increment comment '主键id',
  `projectid` int(11) default 0 comment '项目id',
  `docname` varchar(100) default '' comment '文档的名称',
  `docfile` varchar(200) default '' comment '上传文档的文件名',
  `docsize` int(11) default 0 comment '文件大小',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`pjdocid`),
  key `projectid` (`projectid`)
) engine=myisam default charset=utf8 comment='项目的文档';

-- 项目版本(项目有很多的版本)
create table if not exists `quickbug_project_vers` (
  `verid` int(11) not null auto_increment comment '主键id',
  `projectid` int(11) default 0 comment '项目id',
  `vername` varchar(100) default '' comment '版本名,如: Ver1.0',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`verid`),
  key `projectid` (`projectid`)
) engine=myisam default charset=utf8 comment='项目版本';

-- 项目模块(项目有很多的模块)
create table if not exists `quickbug_project_modules` (
  `moduleid` int(11) not null auto_increment comment '主键id',
  `projectid` int(11) default 0 comment '项目id',
  `modulename` varchar(100) default '' comment '模块名',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`moduleid`),
  key `projectid` (`projectid`)
) engine=myisam default charset=utf8 comment='项目模块';

-- -------------------------------------------------------------------------------------------------------------

-- BUG列表
create table if not exists `quickbug_bugs` (
  `bugid` int(11) not null auto_increment comment '主键id',
  `projectid` int(11) not null default 0 comment '项目id',
  `verid` int(11) not null default 0 comment '版本id',
  `moduleid` int(11) not null default 0 comment '模块id',
  `subject` varchar(250) default '' comment '标题',
  `info` text default '' comment '详细描述(这里用户可以自定义bug模板)',
  `groupid` int(11) not null default 0 comment '用户组id',
  `createuid` int(11) not null default 0 comment '创建者用户id',
  `touserid` int(11) not null default 0 comment '处理者用户id',
  `severity` tinyint(4) default 1 comment '严重程度--具体看配置',
  `frequency` tinyint(4) default 1 comment '重现规律--具体看配置',
  `priority` tinyint(4) default '3' COMMENT '优先级--具体看配置',
  `bugtype` tinyint(4) default 1 comment '缺陷类型--具体看配置',
  `status` tinyint(4) default 1 comment '状态--具体看配置',
  `savetype` tinyint(4) default 1 comment '保存类型: 1:正常 0:草稿',
  `dateline` int(11) default 0 comment '记录时间',
  `lastuptime` int(11) default 0 comment '最后操作时间(所有操作)',
  primary key (`bugid`),
  key `projectid` (`projectid`),
  key `verid` (`verid`),
  key `moduleid` (`moduleid`),
  key `createuid` (`createuid`),
  key `touserid` (`touserid`),
  key `severity` (`severity`),
  key `status` (`status`)
) engine=myisam default charset=utf8 auto_increment=1000 comment='BUG列表';


-- BUG文档附件
create table if not exists `quickbug_bug_docs` (
  `bugdocid` int(11) not null auto_increment comment '主键id',
  `bugid` int(11) default 0 comment 'BUG id',
  `docname` varchar(100) default '' comment '文档的名称',
  `docfile` varchar(200) default '' comment '上传文档的文件名',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`bugdocid`),
  key `bugid` (`bugid`)
) engine=myisam default charset=utf8 comment='BUG文档附件';

-- -----------------------------------------------------------------------------------------

-- BUG变更历史
create table if not exists `quickbug_bug_history` (
  `id` int(11) not null auto_increment comment '主键id',
  `bugid` int(11) not null default 0 comment 'BUG id',
  `historydata` text default '' comment '上一次修改前的BUG序列化后的信息',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`id`),
  key `bugid` (`bugid`)
) engine=myisam default charset=utf8 comment='BUG变更历史';

-- BUG操作历史
create table if not exists `quickbug_operate_history` (
  `id` int(11) not null auto_increment comment '主键id',
  `bugid` int(11) not null default 0 comment 'BUG id',
  `userid` int(11) not null default 0 comment '用户 id',
  `text` text default '' comment '操作简介内容',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`id`),
  key `bugid` (`bugid`)
) engine=myisam default charset=utf8 comment='BUG操作历史';

-- 自定义BUG模板
create table if not exists `quickbug_bug_tpls` (
  `id` int(11) not null auto_increment comment '主键id',
  `userid` int(11) not null default 0 comment '用户id',
  `tplname` varchar(100) default '' comment '模块名称',
  `tplhtml` text default '' comment '模块内容',
  primary key (`id`),
  key `userid` (`userid`)
) engine=myisam default charset=utf8 comment='自定义BUG模块';


-- BUG 评论/处理意见
create table if not exists `quickbug_bug_comment` (
  `commentid` int(11) not null auto_increment comment '主键id',
  `bugid` int(11) default 0 comment 'BUG id',
  `userid` int(11) default 0 comment '用户id',
  `username` varchar(100) default '' comment '用户名',
  `info` text default '' comment '内容',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`commentid`),
  key `bugid` (`bugid`)
) engine=myisam default charset=utf8 comment='BUG 评论/处理意见';

-- BUG 讨论邀请/通知
create table if not exists `quickbug_bug_invite` (
  `inviteid` int(11) not null auto_increment comment '主键id',
  `bugid` int(11) default 0 comment 'BUG id',
  `userid` int(11) default 0 comment '操作用户id',
  `ivtuserid` int(11) default 0 comment '被邀请/通知的用户id',
  `opt` tinyint(4) default 0 comment '操作选择: 0:创建BUG时的处理人通知 1:创建BUG时的邀请Ta人 2:编辑BUG时的通知处理人 3:浏览BUG时的通知对方 4:浏览BUG时的邀请参与者',
  `isread` tinyint(4) default 0 comment '是否已读: 0:新消息 1:已读消息',
  `dateline` int(11) default 0 comment '记录时间',
  primary key (`inviteid`),
  key `bugid` (`bugid`),
  key `ivtuserid` (`ivtuserid`,`isread`)
) engine=myisam default charset=utf8 comment='BUG 讨论邀请/通知';

