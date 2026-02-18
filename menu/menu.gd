extends Control

#Falta poner que apunte a enviorment
# TODO
func _onBtnStartPressed():
	get_tree().change_scene_to_file("res://environment/environment.tscn")

func _onBtnEndPressed():
	get_tree().quit()
