package ui.modal.panel;

import js.Browser;
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

		// Create quick search
		search = new ui.QuickSearch( jContent.find(".structList ul") );
		search.jWrapper.appendTo( jContent.find(".search") );

		if( project.defs.structs.length>0 )
			selectStruct( project.defs.structs[0] );

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

		// List context menu
		ContextMenu.attachTo(jStructList, false, [
			{
				label: L._Paste(),
				cb: ()->{
					var copy = project.defs.pasteStructDef(App.ME.clipboard);
					editor.ge.emit(StructDefAdded);
					selectStruct(copy);
				},
				enable: ()->App.ME.clipboard.is(CStructDef),
			},
		]);

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

			for(sd in group.all) {
				var jLi = new J('<li class="draggable"/>');
				jLi.appendTo(jSubList);
				jLi.data("uid", sd.uid);
				if( sd==curStruct )
					jLi.addClass("active");
				jLi.append('<span class="name">'+sd.identifier+'</span>');
				jLi.click( function(_) {
					selectStruct(sd);
				});

				ContextMenu.attachTo_new(jLi, (ctx:ContextMenu)->{
					ctx.addElement( Ctx_CopyPaster({
						elementName: "struct",
						clipType: CStructDef,

						copy: ()->App.ME.clipboard.copyData(CStructDef, sd.toJson(project)),
						cut: ()->{
							App.ME.clipboard.copyData(CStructDef, sd.toJson(project));
							deleteStructDef(sd, true);
						},
						paste: ()->{
							var copy = project.defs.pasteStructDef(App.ME.clipboard, sd);
							editor.ge.emit(EnumDefAdded);
							selectStruct(copy);
						},
						duplicate: ()->{
							var copy = project.defs.duplicateStructDef(sd);
							editor.ge.emit(EnumDefAdded);
							selectStruct(copy);
						},
						delete: ()->deleteStructDef(sd,true),
					}) );
				});

			}

			// Make sub list sortable
			JsTools.makeSortable(jSubList, function(ev) {
				var jItem = new J(ev.item);
				var fromIdx = project.defs.getStructIndex( jItem.data("uid") );
				var toIdx = ev.newIndex>ev.oldIndex
					? jItem.prev().length==0 ? 0 : project.defs.getStructIndex( jItem.prev().data("uid") )
					: jItem.next().length==0 ? project.defs.structs.length-1 : project.defs.getStructIndex( jItem.next().data("uid") );

				var moved = project.defs.sortStructDef(fromIdx, toIdx);
				selectStruct(moved);
				editor.ge.emit(StructDefSorted);
			}, { onlyDraggables:true });

		}

		JsTools.parseComponents(jStructList);
		search.run();
	}

	function deleteStructDef(ed:data.def.StructDef, fromContext:Bool) {
		// Local enum removal
		function _delete() {
			new ui.LastChance( L.t._("Struct ::name:: deleted", { name: ed.identifier}), project );
			project.defs.removeStructDef(ed);
			editor.ge.emit(StructDefRemoved);
			selectStruct( project.defs.structs[0] );
		}
		var isUsed = project.isStructDefUsed(ed);
		Browser.console.log(isUsed);
		
		if( !isUsed && !fromContext )
			new ui.modal.dialog.Confirm(Lang.t._("This struct is not used and can be safely removed."), _delete);
		else if( isUsed )
			new ui.modal.dialog.Confirm(
				Lang.t._("WARNING! This STRUCT is used in one or more entity/level fields. These fields will also be deleted!"),
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

