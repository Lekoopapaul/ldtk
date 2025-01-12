package ui.modal.panel;

import data.DataTypes;

class EditStructDefs extends ui.modal.Panel{
	var curStruct : Null<data.def.StructDef>;
	var search : QuickSearch;
	public var fieldsForm : FieldDefsForm;


    public function new(){
        super();

		loadTemplate("editStructDefs","defEditor structDefs");
		linkToButton("button.editStructs");

		jContent.find("button.create").click( function(_) {
			var ed = project.defs.createStructDef();
			editor.ge.emit(StructDefAdded);
			selectStruct(ed);
			jContent.find("input:first").focus();
		});

		// Create fields editor
		fieldsForm = new ui.FieldDefsForm( FP_Struct(null) );
		jContent.find("#fields").replaceWith( fieldsForm.jWrapper );

		updateStructList();
		updateStructForm();
        
    }

    override function onGlobalEvent(e:GlobalEvent) {
		super.onGlobalEvent(e);
		switch e {
			case ProjectSettingsChanged, LevelSettingsChanged(_), LevelSelected(_):
				close();

			case ProjectSelected:
				updateStructForm();
				updateFieldsForm();
				updateStructList();
				selectStruct(project.defs.structs[0]);
				
			case LayerInstancesRestoredFromHistory(_):
				updateStructForm();
				updateFieldsForm();
				updateStructList();

			case StructDefChanged, StructDefAdded, StructDefRemoved:
				updateStructList();
				updateStructForm();
				updateFieldsForm();

			case StructDefSorted, FieldDefSorted:
				updateStructList();

			case FieldDefAdded(_), FieldDefRemoved(_), FieldDefChanged(_):
				updateStructForm();
				updateFieldsForm();

			case ExternalEnumsLoaded(anyCriticalChange):
				updateStructList();
				updateFieldsForm();
			
			case _:
		}
	}

	public function selectStruct(ed:data.def.StructDef) {
		curStruct = ed;
		updateStructList();
		updateStructForm();
		updateFieldsForm();
	}

	function updateStructList(){
		var jStructList = jContent.find(".structList>ul");
		jStructList.empty();

		var tagGroups = project.defs.groupUsingTags(project.defs.structs, ed->ed.tags);
		for( group in tagGroups) {
			// Tag name
			if( tagGroups.length>1 ) {
				var jSep = new J('<li class="title collapser"/>');
				jSep.text( group.tag==null ? L._Untagged() : group.tag );
				jSep.appendTo(jStructList);
				jSep.attr("id", project.iid+"_struct_tag_"+group.tag);
				jSep.attr("default", "open");
			}

			var jLi = new J('<li class="subList draggable"/>');
			jLi.appendTo(jStructList);
			var jSubList = new J('<ul class="niceList compact"/>');
			jSubList.appendTo(jLi);

			for(ed in group.all) {
				var jLi = new J('<li class="draggable"/>');
				jLi.appendTo(jSubList);
				jLi.data("uid", ed.uid);
				if( ed==curStruct )
					jLi.addClass("active");
				jLi.append('<span class="name">'+ed.identifier+'</span>');
				jLi.click( function(_) {
					selectStruct(ed);
				});

			}

		}
	}

	function deleteStructDef(ed:data.def.StructDef, fromContext:Bool) {
		// Local enum removal
		function _delete() {
			new ui.LastChance( L.t._("Enum ::name:: deleted", { name: ed.identifier}), project );
			project.defs.removeStructDef(ed);
			editor.ge.emit(EnumDefRemoved);
			selectStruct( project.defs.structs[0] );
		}
		var isUsed = project.isStructDefUsed(ed);
		if( !isUsed && !fromContext )
			new ui.modal.dialog.Confirm(Lang.t._("This struct is not used and can be safely removed."), _delete);
		else if( isUsed )
			new ui.modal.dialog.Confirm(
				Lang.t._("WARNING! This STRUCT is used in one or more entity fields. These fields will also be deleted!"),
				true,
				_delete
			);
		else
			_delete();

	}

	function updateStructForm(){
		var form = jContent.find(".structForm");
		//form.find("*").off();

		if(curStruct == null){
			form.hide();
			return;
		}
		form.show();

		//Identifier
		var i = Input.linkToHtmlInput( curStruct.identifier, form.find("[name=id]") );
		i.fixValue = (v)->project.fixUniqueIdStr(v, (id)->project.defs.isStructIdentifierUnique(id, curStruct));
		i.linkEvent(StructDefChanged);
		
		// Tags
		var ted = new TagEditor(
			curStruct.tags,
			()->editor.ge.emit(StructDefChanged),
			()->project.defs.getRecallTags(project.defs.enums, ed->ed.tags),
			()->project.defs.structs.map( structDef->structDef.tags ),
			(oldT,newT)->{
				for(structDef in project.defs.structs)
					structDef.tags.rename(oldT,newT);
				editor.ge.emit( StructDefChanged );
			}
		);
		form.find("#tags").empty().append(ted.jEditor);

		
	}

	function updateFieldsForm(){
		if( curStruct!=null )
			fieldsForm.useFields(FP_Struct(curStruct), curStruct.fieldDefs);
		else {
			fieldsForm.useFields(FP_Struct(null), []);
			fieldsForm.hide();
		}
	}


}

