@tool
extends EditorPlugin
var reanim_dialog
var output_dialog
var res_dialog

var reanim_file_path: String;
var output_file_path: String;
var res_path: String;

#const CONVERTER_PATH: String = "res://addons/godotreanimreader/bin/win64/PVZ_reanim2godot_animation.exe"

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_tool_menu_item("转换Reanim到Godot", _get_ready)
	
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item("转换Reanim到Godot")
	pass


func _get_ready() -> void:
	print("收集参数...")
	var exe_path = _get_converter_path()
	if exe_path == "":
		return
	print("exe_path: " + exe_path)
	
	# 第一步：选择reanim源文件
	_select_reanim_file_path()
	# 第二步：选择输出文件
	# 第三步：选择资源目录

func _convert_reanim() -> void:
	print("开始转换...")
	var args = [
		reanim_file_path,
		output_file_path,
		res_path,
		"tscn"
	]
	print(ProjectSettings.globalize_path(_get_converter_path()))
	print(args)
	var output = []
	var exit_code = OS.execute(
		ProjectSettings.globalize_path(_get_converter_path()),
		args,
		output,
		true
		)
	if exit_code == 0:
		print("转换成功！")
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("转换失败：%s" % output)


func _select_reanim_file_path() -> void:
	reanim_dialog = EditorFileDialog.new()
	if reanim_dialog == null:
		push_error("reanim_dialog is null!")
		return;
	_setup_file_dialog(
		reanim_dialog,
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		EditorFileDialog.ACCESS_FILESYSTEM,
		"请选择reanim源文件",
		["*.reanim", "*.txt"],
		_set_reanim_file_path
	)
func _set_reanim_file_path(path: String) -> void:
	reanim_file_path = path
	print("reanim_file_path: " + reanim_file_path)
	# 第二步：选择输出文件
	_select_output_file_path()
	
func _select_output_file_path() -> void:
	output_dialog = EditorFileDialog.new()
	if output_dialog == null:
		push_error("output_dialog is null!")
		return;
	_setup_file_dialog(
		output_dialog,
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		EditorFileDialog.ACCESS_FILESYSTEM,
		"请选择输出场景文件",
		["*.tscn"],
		_set_output_file_path
	)
func _set_output_file_path(path: String) -> void:
	output_file_path = path
	print("output_file_path: " + output_file_path)
	# 第三步：选择资源目录
	_select_res_path()

func _select_res_path() -> void:
	res_dialog = EditorFileDialog.new()
	if res_dialog == null:
		push_error("res_dialog is null!")
		return;
	_setup_file_dialog(
		res_dialog,
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		EditorFileDialog.ACCESS_RESOURCES,
		"请选择素材文件夹",
		["*.reanim", "*.txt"],
		_set_res_path
	)
func _set_res_path(path: String) -> void:
	res_path = path
	print("res_path: " + res_path)
	_convert_reanim()

func _get_converter_path() -> String:
	# 根据平台获取可执行文件路径
	var os_name = OS.get_name()
	var base_path = "res://addons/godotreanimreader/bin/"
	
	match os_name:
		"Windows":
			return base_path.path_join("win32/PVZ_reanim2godot_animation.exe")
		"Linux":
			push_error("Sorry, this plugin is not yet supported on the Linux platform, but we are working on it.\nThank you for your understanding.")
			return ""
			#return base_path.path_join("linux/PVZ_reanim2godot_animation")
		_:
			push_error("Unsupported platform: " + os_name)
			return ""

func _setup_file_dialog(
	dialog: EditorFileDialog, 
	mode: EditorFileDialog.FileMode, 
	access: EditorFileDialog.Access,
	title: String, 
	filters, 
	callback_set
	) -> void:
	
	dialog.file_mode = mode
	dialog.title = title
	dialog.access = access
	dialog.clear_filters()
	
	for filter in filters:
		dialog.add_filter(filter)
	if callback_set != null:
		if (dialog.file_mode == EditorFileDialog.FILE_MODE_OPEN_FILE || dialog.file_mode == EditorFileDialog.FILE_MODE_SAVE_FILE):
			dialog.file_selected.connect(callback_set)
		elif dialog.file_mode == EditorFileDialog.FILE_MODE_OPEN_DIR:
			dialog.dir_selected.connect(callback_set)
		else:
			dialog.file_selected.connect(callback_set)
			dialog.dir_selected.connect(callback_set)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.6)
