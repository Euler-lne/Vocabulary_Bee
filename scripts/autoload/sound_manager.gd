extends Node

# ====================
# 音效路径（你写的）
# ====================
const gun_shot_sfx_path = "res://assets/SFX/universfield-gunshot-352466.mp3"
const gun_shot_miss_sfx_path = "res://assets/SFX/game-closing-sound.mp3"
const game_over_sfx_path = "res://assets/SFX/alphix-game-over-417465.mp3"

# ====================
# 音量（外部可修改）
# ====================
@export var sfx_volume: float = 0.8  # 全局音量 0~1


# ====================
# 音频播放器
# ====================
var audio_player: AudioStreamPlayer


func _ready():
	# 创建播放器（Web 端兼容）
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = "Master"  # 关键：Web 端必须走音频总线


# ====================
# 播放接口
# ====================
func play_gun_shot():
	_play(gun_shot_sfx_path)

func play_gun_shot_miss():
	_play(gun_shot_miss_sfx_path)

func play_game_over():
	_play(game_over_sfx_path)


# ====================
# 内部播放（支持 Web）
# ====================
func _play(path: String):
	var audio = load(path)
	if not audio:
		return

	audio_player.stream = audio
	audio_player.volume_db = linear_to_db(sfx_volume) # 音量设置
	audio_player.play()


# ====================
# 外部动态修改音量
# ====================
func set_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
