package data.inst;

class StructInstance{
    public var _project : Project;
    public var def(get,never) : data.def.StructDef; inline function get_def() return _project.defs.getStructDef(defUid);

    public var iid : String;
	public var defUid(default,null) : Int;

    public var fieldInstances : Map<Int, data.inst.FieldInstance> = new Map();

    public function new(p:Project, structDefUid:Int,iid:String) {
		_project = p;
		defUid = structDefUid;
		this.iid = iid;
	}

    @:keep public function toString() {
		return 'StructInst "${def.identifier}"';
	}

    public function toJson(li:data.inst.LayerInstance) : ldtk.Json.StructInstanceJson {
		var json : ldtk.Json.StructInstanceJson = {
			// Fields preceded by "__" are only exported to facilitate parsing
			__identifier: def.identifier,

			iid: iid,
			defUid: defUid,
			fieldInstances: {
				var all = [];
				for(fd in def.fieldDefs)
					all.push( getFieldInstance(fd,true).toJson() );
				all;
			}
		}

		return json;
	}

    public static function fromJson(project:Project, json:ldtk.Json.StructInstanceJson) {
		if( (cast json).defId!=null ) // Convert renamed defId
			json.defUid = (cast json).defId;

		if( json.iid==null ) // Init IID
			json.iid = project.generateUniqueId_UUID();

		var si = new StructInstance(project, JsonTools.readInt(json.defUid), json.iid);

		for( fieldJson in JsonTools.readArray(json.fieldInstances) ) {
			var fi = FieldInstance.fromJson(project, fieldJson);
			si.fieldInstances.set(fi.defUid, fi);
		}

		return si;
	}

    public function getFieldInstance(fieldDef:data.def.FieldDef, createIfMissing:Bool) {
		if( createIfMissing && !fieldInstances.exists(fieldDef.uid) )
			fieldInstances.set(fieldDef.uid, new data.inst.FieldInstance(_project, fieldDef.uid));
		return fieldInstances.get( fieldDef.uid );
	}
}