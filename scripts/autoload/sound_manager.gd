extends Node

# ====================
# 音效路径
# ====================
const gun_shot_sfx_path = "res://assets/SFX/universfield-gunshot-352466.mp3"
const gun_shot_miss_sfx_path = "res://assets/SFX/game-closing-sound.mp3"
const game_over_sfx_path = "res://assets/SFX/alphix-game-over-417465.mp3"

# ====================
# 开关 & 音量
# ====================
static var is_fx_enabled := true
@export var sfx_volume: float = 0.7

# ====================
# TTS
# ====================
var _tts_voice_id: String = ""

# ====================
# 播放器
# ====================
var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = "Master"
	_init_tts()

func _init_tts():
	var voices = DisplayServer.tts_get_voices_for_language("en")
	if voices.size() > 0:
		_tts_voice_id = voices[0]
	else:
		var all_voices = DisplayServer.tts_get_voices()
		if all_voices.size() > 0:
			_tts_voice_id = all_voices[0]

# 播放单词（安全音量，不会静音）
func speak_word(word: String):
	if _tts_voice_id != "":
		# 最低音量保护：永远 ≥ 0.1
		DisplayServer.tts_speak(word, _tts_voice_id)

# 开枪音效：单独减弱 0.75 倍
func play_correct():
	if is_fx_enabled:
		_play(gun_shot_sfx_path, sfx_volume * 0.5)

func play_wrong():
	if is_fx_enabled:
		_play(gun_shot_miss_sfx_path, sfx_volume)

func play_game_over():
	if is_fx_enabled:
		_play(game_over_sfx_path, sfx_volume)

# 内部播放
func _play(path: String, volume: float):
	var audio = load(path)
	if not audio:
		return
	audio_player.stream = audio
	audio_player.volume_db = linear_to_db(volume)
	audio_player.play()
