extends Node

var tweens: Array[Tween] = []

func _ready() -> void:
    GameManager.game_state_changed.connect(on_game_state_changed)
    GridData.downtime_changed.connect(on_downtime_changed)

func on_game_state_changed(game_state: GameManager.GameState):
    if game_state in [GameManager.GameState.PAUSED, GameManager.GameState.GAME_OVER]:
        pause()
    if game_state == GameManager.GameState.PLAYING:
        resume()

func on_downtime_changed(downtime):
    if downtime:
        pause()
    else:
        resume()

func add_new_tween() -> Tween:
    remove_invalid_tweens()
    var tween = get_tree().create_tween()
    tweens.append(tween)
    return tween

func remove_invalid_tweens():
    var bad_tweens = []
    for tween in tweens:
        if not is_instance_valid(tween) or not tween.is_valid():
            bad_tweens.append(tween)
    for bad_tween in bad_tweens:
        tweens.erase(bad_tween)

func pause():
    remove_invalid_tweens()
    for tween in tweens:
        tween.pause()

func resume():
    remove_invalid_tweens()
    for tween in tweens:
        tween.play()


