<?php
/**
 * 系统相关配置
 *
 * @category QuickBug
 */
return array(

	// RTX服务器网关配置
	'rtx'=>array(
		'enable'=>false, // RTX通知是否可用
		'host'=>'rtx.domain.com', // 主机或IP地址
		'port'=>8012, // WEB网关的端口，默认是 8012
	),

	// 邮件服务器配置
	'mail'=>array(
		'enable'=>true, // 邮件通知是否可用
		'host'=>'smtp.exmail.qq.com',// SMTP服务器的主机或IP地址
		'port'=>25,// SMTP端口，默认是 25
		'auth'=>true,// 是否要有身份认证
		'secure'=>'', // 连接协议 "":默认  "ssl":HTTPS  "tls":TLS
		'username'=>'quickbug@vcomputes.com',// 用户名
		'password'=>'Quickbug2016',// 密码
		'from'=>'quickbug@vcomputes.com',// 发送者
		'fromname'=>'QuickBug System V1.5',//标题
	),

	// 当前系统域名或IP,这个主要是用于RTX通知和邮件中的,格式如:"http://quickbug.com" 无需以 "/" 结束
	'domain'=>'http://www.vcomputes.com',
	// 系统路径，该路径是相对根域名，如果是根域名则使用 "/" 否则配置为实际路径，如:"/quickbug/Public/"
	'path'=>'/quickbug/Public/',

	// 当前系统语言 zh:中文 en:英文
	'lang'=>'zh',
);