package led;

@display("Json root")
typedef ProjectJson = {
	/** File format version **/
	var jsonVersion: String;

	/** Default X pivot (0 to 1) for new entities **/
	var defaultPivotX: Float;

	/** Default Y pivot (0 to 1) for new entities **/
	var defaultPivotY: Float;

	/** Default grid size for new layers **/
	var defaultGridSize: Int;

	/** Project background color **/
	@color
	var bgColor: String;

	@hide
	var nextUid: Int;

	/** If TRUE, the Json is partially minified (no indentation, nor line breaks) **/
	var minifyJson: Bool;

	/** If TRUE, a Tiled compatible file will also be generated along with the LEd JSON file. **/
	var exportTiled: Bool;

	/** A structure containing all the definitions of this project **/
	var defs: DefinitionsJson;

	var levels: Array<LevelJson>;
}


@section("1")
@display("Level")
typedef LevelJson = {

	/** Unique Int identifier **/
	var uid: Int;

	/** Unique String identifier **/
	var identifier: String;

	/** Width of the level in pixels **/
	var pxWid: Int;

	/** Height of the level in pixels **/
	var pxHei: Int;

	var layerInstances: Array<LayerInstanceJson>;
}


@section("1.1")
@display("Layer instance")
typedef LayerInstanceJson = {
	/** Unique String identifier **/
	var __identifier: String;

	/** Layer type (possible values: IntGrid, Entities, Tiles or AutoLayer) **/
	var __type: String;

	/** Grid-based width **/
	var __cWid: Int;

	/** Grid-based height **/
	var __cHei: Int;

	/** Grid size **/
	var __gridSize: Int;

	/** Reference to the UID of the level containing this layer instance **/
	var levelId: Int;

	/** Reference the Layer definition UID **/
	var layerDefUid: Int;

	/** Horizontal offset in pixels to render this layer, usually 0 **/
	var pxOffsetX: Int;

	/** Vertical offset in pixels to render this layer, usually 0 **/
	var pxOffsetY: Int;

	/** Random seed used for Auto-Layers rendering **/
	@only("Auto-layers (pure or IntGrid based)")
	var seed: Int;

	@only("IntGrid layers")
	var intGrid: Array<{
		/** Coordinate ID in the layer grid **/
		var coordId:Int;

		/** IntGrid value **/
		var v:Int;
	}>;

	@only("Tile layers")
	var gridTiles: Array<{
		/** Coordinate ID in the layer grid **/
		var coordId: Int;

		/** Tile ID in the corresponding tileset **/
		var tileId: Int;

		/** X pixel coordinate of the tile in the **layer** **/
		@added("0.3.0")
		var __x: Int;

		/** Y pixel coordinate of the tile in the **layer** **/
		@added("0.3.0")
		var __y: Int;

		/** X pixel coordinate of the tile in the **tileset** **/
		@changed("0.3.0")
		var __srcX: Int;

		/** Y pixel coordinate of the tile in the **tileset** **/
		@changed("0.3.0")
		var __srcY: Int;
	}>;


	/**
		An array containing all tiles generated by Auto-layer rules. The array is already
		sorted in display order (ie. 2nd array should be displayed "above" 1st)
	**/
	@only("Auto-layers")
	@changed("0.4.0")
	var autoTiles2: Array<{
		/** X pixel coordinate of the tile in the **layer** **/
		var x: Int;

		/** Y pixel coordinate of the tile in the **layer** **/
		var y: Int;

		/** X pixel coordinate of the tile in the **tileset** **/
		var srcX: Int;

		/** Y pixel coordinate of the tile in the **tileset** **/
		var srcY: Int;

		/** A 2-bits integer to represent the mirror transformations of the tile: Bit 0 = X flip, Bit 1 = Y flip **/
		var f: Int;

		/** The rule UID that created this tile **/
		var r: Int;

		/** The coordinate ID of the grid cell that triggered the rule **/
		var c: Int;
	}>;

	@only("Auto-layers")
	var autoTiles: Array<{
		var ruleId: Int;
		@changed("0.3.0")
		var results: Array<{
			/** Coordinate ID in the layer grid **/
			var coordId: Int;

			/** Grid-based X coordinate of the cell **/
			@added("0.3.1")
			var __cx: Int;

			/** Grid-based Y coordinate of the cell **/
			@added("0.3.1")
			var __cy: Int;

			/** A 2-bits integer: Bit 0 = X flip, Bit 1 = Y flip **/
			var flips: Int;

			/** An array of all the tiles generated by the corresponding rule: **/
			@added("0.3.0")
			var tiles: Array<{
				/** Tile ID in the corresponding tileset **/
				var tileId: Int;

				/** X pixel coordinate of the tile in the **layer** **/
				@changed("0.3.0")
				var __x: Int;

				/** Y pixel coordinate of the tile in the **layer** **/
				@changed("0.3.0")
				var __y: Int;

				/** X pixel coordinate of the tile in the **tileset** **/
				@changed("0.3.0")
				var __srcX: Int;

				/** Y pixel coordinate of the tile in the **tileset** **/
				@changed("0.3.0")
				var __srcY: Int;
			}>;
		}>;
	}>;

	@only("Entity layers")
	var entityInstances: Array<EntityInstanceJson>;
}

@section("1.1.1")
@display("Entity instance")
typedef EntityInstanceJson = {
	/** Unique String identifier **/
	var __identifier: String;

	/** Grid-based X coordinate **/
	var __cx: Int;

	/** Grid-based Y coordinate **/
	var __cy: Int;

	/** Reference of the **Entity definition** UID **/
	var defUid: Int;

	/** Pixel X coordinate **/
	var x: Int;

	/** Pixel Y coordinate **/
	var y: Int;

	var fieldInstances: Array<FieldInstanceJson>;
}


@section("1.1.2")
@display("Field instance")
typedef FieldInstanceJson = {
	/** Unique String identifier **/
	var __identifier: String;

	/** Actual value of the field instance. The value type may vary, depending on `__type` (Integer, Boolean, String etc.) **/
	var __value: Dynamic;

	/** Type of the field, such as Int, Float, Enum(enum_name), Bool, etc. **/
	var __type: String;

	/** Reference of the **Field definition** UID **/
	var defUid: Int;

	@hide
	var realEditorValues: Array<Dynamic>;
}


/**
	Many useful data found in `definitions` are duplicated in fields
	prefixed with a double "_".
**/
@section("2")
@display("Definitions")
typedef DefinitionsJson = {
	var layers : Array<LayerDefJson>;
	var entities : Array<EntityDefJson>;
	var tilesets : Array<TilesetDefJson>;
	var enums : Array<EnumDefJson>;

	/**
		Note: external enums are exactly the same as `enums`, except they
		have a `relPath` to point to an external source file.
	**/
	var externalEnums : Array<EnumDefJson>;
}


@section("2.1")
@display("Layer definition")
typedef LayerDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Type of the layer (*IntGrid, Entities, Tiles or AutoLayer*) **/
	var __type: String;

	/** Type of the layer as Haxe Enum **/
	@hide
	var type: led.LedTypes.LayerType;

	/** Unique Int identifier **/
	var uid: Int;

	var gridSize: Int;

	/** Opacity of the layer (0 to 1.0) **/
	var displayOpacity: Float;

	@only("IntGrid layer")
	var intGridValues: Array<{
		var identifier:String;

		@color
		var color:String ;
	}>;

	/** Reference to the Tileset UID being used by this auto-layer rules **/
	@only("Auto-layers")
	var autoTilesetDefUid: Int;

	/** This array contains all the auto-layer rule definitions **/
	@only("Auto-layers")
	var autoRuleGroups: Array<{
		var uid: Int;
		var name: String;
		var active: Bool;
		var collapsed: Bool;
		var rules: Array<Dynamic>;
	}>;
	@only("Auto-layers")
	var autoSourceLayerDefUid: Int;

	/** Reference to the Tileset UID being used by this tile layer **/
	@only("Tile layers")
	var tilesetDefUid: Int;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	var tilePivotX: Float;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	var tilePivotY: Float;

}

/** Not available yet**/
@section("2.2")
@display("Entity definition")
typedef EntityDefJson = Dynamic;

@section("2.3")
@display("Tileset definition")
typedef TilesetDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Unique Intidentifier **/
	var uid: Int;

	/** Path to the source file, relative to the current project JSON file **/
	var relPath: String;

	/** Image width in pixels **/
	var pxWid: Int;

	/** Image width in pixels **/
	var pxHei: Int;

	var tileGridSize: Int;

	/** Space in pixels between all tiles **/
	var spacing: Int;

	/** Distance in pixels from image borders **/
	var padding: Int;

	/** Array of group of tiles selections, only meant to be used in the editor **/
	@hide
	var savedSelections: Array<{ ids:Array<Int>, mode:Dynamic }>;
}

/** Not available yet**/
@section("2.4")
@display("Enum definition")
typedef EnumDefJson = Dynamic;
