<?php
/**
 * HMVC 插件，让框架支持基于 HMVC 的开发
 *
 * @category QuickPHP(II)
 * @copyright http://www.vquickphp.com
 * @version $Id: Hmvc.php 1236 2012-09-28 15:20:02Z yuanwei $
 */
class QP_Hmvc_Hmvc
{
	/**
	 * 防止类实例化或被复制
	 *
	 */
	private function __construct(){}
	private function __clone(){}
	
	/**
	 * 当前控制器相对路径
	 *
	 * @var string
	 */
	private static $_controllerPath = '';
	
	/**
	 * 运行指定的控制器中的运行并返回所有输出的结果
	 *
	 * @param string $controllerName 控制器名称,如:"index"或"admin_admin"
	 * @param string $actionName  动作名,默认为 'index'
	 * @param array $params 参数数组，如：array('id'=>1,'name'=>'yuanwei')
	 * 
	 * @example 
	 * 在视图中调用一个公共的 header 内容
	 * <?php echo QP_Hmvc_Hmvc::load('public','header')?> // 相当于执行了 publicController->headerAction() 方法
	 */
	static public function load($controllerName, $actionName=QP_Controller::DEFAULT_ACTION, $params=array())
	{
		// 注入http参数，供控制器中使用
		self::_parseParam($params);
		
		// 得到最终控制器和动作
		$actionName = ucfirst($actionName);
		$controller = self::_getController($controllerName);
		$action = $actionName.'Action';
		
		// 判断动作是否存在
		if(! method_exists($controller,$action)){
			throw new QP_Exception('控制器:'.get_class($controller).' 中未定义动作:'.$action, QP_Exception::EXCEPTION_NO_ACTION);
		}
		// 把执行的输出先保存起来
		ob_start();
		// 执行 init 方法
		$controller->init();
		// 执行动作
		$controller->$action();
		// 得到所有输出内容
		$viewContent = ob_get_clean();
		
		// 是否自动输出视图
		if($controller->viewIsAutoRender()){
			$controller->view->setPath(self::$_controllerPath);
			$viewContent .= $controller->view->render($actionName.QP_View::getDefaultExt());
		}
		return $viewContent;
	}
	
	/**
	 * 根据控制器名得到控制器对象
	 *
	 * @param string $controllerName
	 * @return object
	 */
	static private function _getController($controllerName)
	{
		$controllerName = ucfirst($controllerName);
		// 处理控制器名是否含有目录的情况,如 "admin_admin"
		if(false !== strpos($controllerName, '_')){
			$arr = array_map('strtolower',explode('_',$controllerName));
			self::$_controllerPath = implode('/',array_map('ucfirst',$arr));
		}else{
			self::$_controllerPath = $controllerName; 
		}	
			
		// 得到控制器文件名
		$controllerFile = APPLICATION_PATH.'/Controllers/'.self::$_controllerPath.'Controller.php';
		if(! file_exists($controllerFile)){
			throw new QP_Exception("控制器不存在:$controllerFile",QP_Exception::EXCEPTION_NO_CONTROLLER);
		}

		// 包含控制器生成对象
		require_once ($controllerFile);
		$className = $controllerName.'Controller';

		// 类是否存在的
		if(! class_exists($className,false)){
			throw new QP_Exception("类:$className 未定义在:$controllerFile");
		}

		// 判断控制器是否继承基类
		$controller = new $className();
		if(! ($controller instanceof QP_Controller)){
			throw new QP_Exception("控制器类 $className 必需继承 QP_Controller 基类");
		}
		return $controller;
	}
	
	/**
	 * 解析参数
	 *
	 * @param array $params
	 */
	static private function _parseParam($params=array())
	{
		// 没有参数
		if(! $params){
			return;
		}
		// 将参数设置给 GET,PARAM 这样在控制器中怎么样都可以得到参数
		QP_Request::getInstance()->setParam($params)->setGet($params);
	}
}

