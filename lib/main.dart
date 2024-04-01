import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/model/Usuario.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _futureUsuarios;
    List<Map<String, dynamic>> _listaUsuarios = [];


  TextEditingController usuarioController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int? idUsuario;
  _openBanco() async {
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, 'banco.db');
    var bd = await openDatabase(path, version: 1,
    onCreate: (db, versaoRecente) async{
      String sql = "CREATE TABLE usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, email VARCHAR)";
      await db.execute(sql);
    });
    print("Banco" + bd.isOpen.toString());
    return bd;
  }


  _salvar(Usuario usuario) async{
    Database db = await _openBanco();
    Map<String, dynamic> dadosUsuario = Map();
    dadosUsuario['id'] = usuario.id;
    dadosUsuario['nome'] = usuario.nome;
    dadosUsuario['email'] = usuario.email;
    setState(() async {
      idUsuario = await db.insert('usuarios', dadosUsuario);
    });
    print(idUsuario);
    setState(() {
      _futureUsuarios = _retornarTodos();
    });
  }

  Future<List<Map<String, dynamic>>> _retornarTodos() async{
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'banco.db') 
    );
    var usuarios = await database.query('usuarios');
    return usuarios;
  }

 /* List <Usuario> usuarios = [
    Usuario( 0,'Usuario 1', 'user1@email.com'),
    Usuario(0,'Usuario 2', 'user2@email.com'),
    Usuario(0,'Usuario 3', 'user3@email.com')
  ];

  Usuario usuario = Usuario(0,'Usuario Principal', 'user@email.com');
  */

  @override
  void initState(){
    super.initState();
    _openBanco();
    _futureUsuarios = _retornarTodos();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3, 
      child: Scaffold(
      appBar: AppBar(
        title: const Text('TabBar Widget'),
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.cloud_outlined),
            ),
            Tab(
              icon: Icon(Icons.beach_access_sharp),
            ),
            Tab(
              icon: Icon(Icons.brightness_5_sharp),
            )
          ],
        ),
      ),
      body:  
      TabBarView(
        children: [
          Center(
           child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                child: TextField(
                    controller: usuarioController,
                    decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Usuário: ',
                    fillColor: Colors.white70,
                    filled: true
              ),
                ),
              ),
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: emailController,
                   decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email: ',
                    fillColor: Colors.white70,
                    filled: true
              ),
                ),  
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    String usuario = usuarioController.text;
                    String email = emailController.text;

                    Usuario user = Usuario(nome:usuario, email:email);
                    await _salvar(user);
                    setState(() {
                      _futureUsuarios;
                      _listaUsuarios;
                    });
                  }, 
                  child: const Text('Login')),
              )
            ],
           ),
           
          ),
          Center(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureUsuarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar os dados');
                } else {
                  final usuarios = snapshot.data ??[];
                  _listaUsuarios = usuarios;
                  return ListView.builder(
                    itemCount: usuarios?.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.1,
                              ),
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            child: Text(usuarios?[index]['nome']),
                          ),
                          const SizedBox(height: 5),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
           /*Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset('assets/images/imagemPerfilFlutter.jpg'),
                  )
                ),
                SizedBox(height: 5),
                Container(
                  child: Container(
                    child: Text(usuario.nome),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(usuario.email),
                )
              ],
            ),
          )*/
        ],
        
      ),
      )
    );
    

   
  }
}
