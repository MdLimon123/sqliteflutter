import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/db_handler.dart';
import 'package:notes/notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes SQL"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: notesList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {

                if(snapshot.hasData){
                  return ListView.builder(
                      reverse: false,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){
                            dbHelper!.update(
                              NotesModel(
                                  id: snapshot.data![index].id!,
                                  title: 'First Flutter note',
                                  age: 22,
                                  description: 'This is Flutter Notes',
                                  email: 'limon123@gmail.com')

                            );
                            setState(() {
                              notesList = dbHelper!.getNotesList();
                            });
                          },
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete_forever),
                            ),
                            onDismissed: (DismissDirection direction){

                              setState(() {
                                dbHelper!.delete(snapshot.data![index].id!);
                                notesList = dbHelper!.getNotesList();
                                snapshot.data!.remove(snapshot.data![index]);

                              });
                            },
                            key: ValueKey<int>(snapshot.data![index].id!),
                            child: Card(
                              child: ListTile(
                                title: Text(snapshot.data![index].title.toString()),
                                subtitle: Text(snapshot.data![index].description.toString()),
                                trailing: Text(snapshot.data![index].age.toString()),
                              ),
                            ),
                          ),
                        );
                      });
                }else{

                  return CircularProgressIndicator();
                }


              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dbHelper!
              .insert(NotesModel(
                  title: 'Lorem Ipsum',
                  age: 21,
                  description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book',
                  email: 'limon@gmail.com'))
              .then((value) {
            print('date added');

            setState(() {
              notesList = dbHelper!.getNotesList();
            });

          }).onError((error, stackTrace) {
            print(error.toString());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
