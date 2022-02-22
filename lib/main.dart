import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:favorite_button/favorite_button.dart';
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

  //Permisos para acceder a los archivos del usuario.
  void getFiles() async{
    PermissionStatus permisos = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
    //Obtenemos los permisos para poder obtener los documentos pdf.
    if (permisos == PermissionStatus.authorized) {
      List<StorageInfo> archivosDisp = await PathProviderEx.getStorageInfo();
      var acc = archivosDisp[0].rootDir;
      var manag = FileManager(root: Directory(acc));
      archivos = await manag.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["pdf"]
      );
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
        title: Text("Biblioteca"), centerTitle: true,
        backgroundColor: Color(0xFFEACFBE),
        actions: <Widget>[IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Favoritos(nombreLibro: "")));}, icon: Icon(Icons.favorite))],
      ),
      body: archivos == null? Center(child: CircularProgressIndicator(color: Color(0xFFEACFBE),)): //Carga, progressBar mientras carga los archivos.
        ListView.builder(
          itemCount: archivos?.length ?? 0,
          itemBuilder: (context, index){
            final item = archivos[index]; //path
            return Dismissible( //Deslizar para eliminar item.
              key: Key(item.toString()),
              onDismissed: (direction){setState((){
                archivos.removeAt(index);
              });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El libro ' +item.toString().substring(36)+ ' se ha eliminado'), backgroundColor: Color(0XFFEACFBE),)); //Mensaje una vez eliminado.
              },
              background: Container( decoration: BoxDecoration(color: Color(0xFFE69287), borderRadius: BorderRadius.circular(3.0)), child: Icon(Icons.delete_outline, color: Colors.white,), alignment: Alignment.centerRight,),
              child: Card( //Lista Card, con los archivos encontrados.
                margin: EdgeInsets.only(right: 0, top: 0.5),
                elevation: 8,
                shadowColor: Colors.black,
                child: ListTile( 
                  title: Text(archivos[index].path.split('/').last),
                  leading: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(5.0)), child: Image.network("https://www.iconpacks.net/icons/2/free-opened-book-icon-3163-thumb.png")),
                  trailing: FavoriteButton(isFavorite: false, valueChanged: (_isFavorite){Navigator.push(context, MaterialPageRoute(builder: (context){return Favoritos(nombreLibro: archivos[index].path.toString());}));}, iconColor: Color(0XFFEACFBE), iconSize: 40.0,),
                  onTap: (){//Muestra archivo pdf seleccionado, pasando su ruta.
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
//Seguir clase favoritos
class Favoritos extends StatelessWidget{
  var nombreLibro="";
  Favoritos({this.nombreLibro}); // Constructor, pasamos ruta archivos.

  @override
  Widget build(BuildContext context) {
    const title = 'Favoritos';
    return MaterialApp(
      title: "Favoritos", 
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFEACFBE),
          title: Text(title),
        ),

        body: ListView.builder( //Lista de libros favoritos
          itemCount: nombreLibro.length,
          itemBuilder: (context, index)=> ListTile(
            leading: Image.network("https://static.thenounproject.com/png/2214917-200.png", ),
            title: Text(nombreLibro[index].toString()),
            )
        ),
      ),
    );
  }
  
}
//Clase para visualizar el pdf seleccionado.
class VisualizarPDF extends StatelessWidget{
  
  String pathPDF = "";
  VisualizarPDF({this.pathPDF}); //Pasamos ruta del libro seleccionado.

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold( //Visualiza pdf.
      appBar: AppBar(
        title: Text(pathPDF.substring(29)),
        backgroundColor: Color(0xFFEACFBE),
      ),
      path: pathPDF, //A partir de la ruta pasada.
    );
  }
}
