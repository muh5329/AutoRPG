class_name ModelFactory
extends RefCounted
## Builds the right CharacterModel subclass for an Appearance.


static func build(appearance: Appearance) -> CharacterModel:
	var model: CharacterModel
	match appearance.body:
		Appearance.Body.RAT: model = RatModel.new()
		Appearance.Body.SPIDER: model = SpiderModel.new()
		_: model = HumanoidModel.new()
	model.name = "Model"
	return model.setup(appearance)
