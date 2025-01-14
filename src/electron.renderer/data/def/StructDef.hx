package data.def;

import data.DataTypes;

class StructDef{
    var _project : Project;

    @:allow(data.Definitions)
	public var uid(default,null) : Int;

    public var identifier(default,set) : String;
	public var tags : Tags;

    public var fieldDefs : Array<data.def.FieldDef> = [];

    public function new(p:Project, uid:Int){
        _project = p;
        this.uid = uid;
        identifier = "Struct"+uid;
        tags = new Tags();
    }

    function set_identifier(id:String) {
		return identifier = Project.isValidIdentifier(id) ? Project.cleanupIdentifier(id, _project.identifierStyle) : identifier;
	}

    @:keep public function toString() {
		return 'StructDef "$identifier" {'
			+ fieldDefs.map( function(fd) return fd.identifier ).join(",")
			+ "}";
	}

    /**Fields Defs**/

    public function createFieldDef(project:Project, type:ldtk.Json.FieldType, baseName:String, isArray:Bool) : FieldDef {
		var f = new FieldDef(project, project.generateUniqueId_int(), type, isArray);
		f.identifier = project.fixUniqueIdStr( baseName + (isArray?"_array":""), Free, (id)->isFieldIdentifierUnique(id) );
		fieldDefs.push(f);
		return f;
	}

	public function sortField(from:Int, to:Int) : Null<FieldDef> {
		if( from<0 || from>=fieldDefs.length || from==to )
			return null;

		if( to<0 || to>=fieldDefs.length )
			return null;

		var moved = fieldDefs.splice(from,1)[0];
		fieldDefs.insert(to, moved);

		return moved;
	}

	public function getFieldDef(id:haxe.extern.EitherType<String,Int>) : Null<FieldDef> {
		for(fd in fieldDefs)
			if( fd.uid==id || fd.identifier==id )
				return fd;

		return null;
	}

	public function isFieldIdentifierUnique(id:String) {
		id = Project.cleanupIdentifier(id,Free);
		for(fd in fieldDefs)
			if( fd.identifier==id )
				return false;
		return true;
	}

    /**JSON data**/

    public static function fromJson(p:Project, json:ldtk.Json.StructDefJson) {
		if( (cast json).name!=null ) json.identifier = (cast json).name;

		var o = new StructDef(p, JsonTools.readInt(json.uid) );
		o.identifier = JsonTools.readString( json.identifier );
		o.tags = Tags.fromJson(json.tags);

		for(defJson in JsonTools.readArray(json.fieldDefs) )
			o.fieldDefs.push( FieldDef.fromJson(p, defJson) );

		return o;
	}

	public function toJson(p:Project) : ldtk.Json.StructDefJson {
		return {
			identifier: identifier,
			uid: uid,
			tags: tags.toJson(),

			fieldDefs: fieldDefs.map( function(fd) return fd.toJson() ),
		}
	}

	public function tidy(){

		// Field defs
		Definitions.tidyFieldDefsArray(_project, fieldDefs, this.toString());

		tags.tidy();
	}

}