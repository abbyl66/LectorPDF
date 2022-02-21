import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() {
  runApp(Lector());
}

class Lector extends StatelessWidget {
  const Lector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LectorLibros(),
    );
  }
}

class LectorLibros extends StatefulWidget{

  @override
  State<StatefulWidget> createState(){
    return _LectorLibros();
  }

}

class _LectorLibros extends State<LectorLibros>{
  var archivos;
  var pageImage;

  void getFiles() async{
    PermissionStatus permisos = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);

    if (permisos == PermissionStatus.authorized) {
      List<StorageInfo> archivosDisp = await PathProviderEx.getStorageInfo();
      var acc = archivosDisp[0].rootDir;
      var manag = FileManager(root: Directory(acc));
      archivos = await manag.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["pdf"]
      );
      setState(() {
        
      });
    }

  }

  @override
  void initState(){
    getFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Libros"),
        backgroundColor: Color(0xFFEACFBE),
      ),
      body: archivos == null? Center(child: CircularProgressIndicator(color: Color(0xFFEACFBE),)): //Carga, progressBar.
        ListView.builder(
          itemCount: archivos?.length ?? 0,
          itemBuilder: (context, index){
            final item = archivos[index];
            return Dismissible( //Deslizar para eliminar item.
              key: Key(item.toString()),
              onDismissed: (direction){setState(() {
                archivos.removeAt(index);
              });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El libro ' +item.toString().substring(36)+ ' se ha eliminado'))); //Mensaje una vez eliminado.
              },
              background: Container( decoration: BoxDecoration(color: Color(0xFFE69287), borderRadius: BorderRadius.circular(3.0)), child: Icon(Icons.delete_outline, color: Colors.white,), alignment: Alignment.centerRight,),
              child: Card(
                margin: EdgeInsets.only(right: 0, top: 0.5),
                elevation: 8,
                shadowColor: Colors.black,
                child: ListTile( 
                  title: Text(archivos[index].path.split('/').last),
                  leading: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(5.0)), child: Image.network("https://www.iconpacks.net/icons/2/free-opened-book-icon-3163-thumb.png")),
                  trailing: Icon(Icons.arrow_forward, color: Color(0xFFEACFBE),),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return VisualizarPDF(pathPDF: archivos[index].path.toString());
                    }));
                  },
                ),
              ),
            );
          }
        )
      ,
    );
  }
  

}


class VisualizarPDF extends StatelessWidget{
  
  String pathPDF = "";
  VisualizarPDF({this.pathPDF});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text(pathPDF.substring(29)),
        backgroundColor: Color(0xFFEACFBE),
      ),
      path: pathPDF,
    );
  }
}
