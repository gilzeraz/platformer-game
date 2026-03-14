extends Resource
class_name CollectibleData
## Resource describing a collectible item.
##
## Defines the data used by collectible objects such as coins or extra lives,
## including display name, coin value, life bonus, and animation frames.


## Display name of the collectible item.
@export var name: String = ""

## Number of coins granted when the item is collected.
@export var coin_value: int = 0

## If [code]true[/code], collecting the item grants an extra life instead of coins.
@export var is_extra_life: bool = false

## Animation frames used to display the collectible sprite.
@export var frames: SpriteFrames
