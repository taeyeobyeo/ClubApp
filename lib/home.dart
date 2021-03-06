import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/club/club.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  int _load =20;
  int _load2 =20;
  void initState() { 
    super.initState();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        setState(() {
          if(_load<10000)
          _load += 20;
        });
      }
    });
    _scrollController2.addListener((){
      if(_scrollController2.position.pixels == _scrollController2.position.maxScrollExtent){
        setState(() {
          if(_load2<10000)
          _load2 += 20;
        });
      }
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.minScrollExtent){
        setState(() {
          _load = 20;
        });
      }
    });
    _scrollController2.addListener((){
      if(_scrollController2.position.pixels == _scrollController2.position.minScrollExtent){
        setState(() {
          _load2 = 20;
        });
      }
    });
  }
  @override
  void dispose() { 
    _scrollController.dispose();
    _scrollController2.dispose();
    super.dispose();
  }
  Future<Null> _clicked(DocumentSnapshot data) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data.data['image']),
            ),
            title: Text(data.data['name']),
            trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey,fontSize: 12.0),),
          ),
          contentPadding: EdgeInsets.all(30.0),
          content: Container(
            child: Text(data.data['advertisement'],maxLines: 5,softWrap: true,),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: ()=>Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("방문",style: TextStyle(color: Colors.white),),
              disabledColor: Colors.grey,
              color: Theme.of(context).primaryColor,
              onPressed: ()async {
                await cu.currentUser.club.enterClub(data);
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ClubPage(data: data),
                  )
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data, int mode) {
    return Padding(
      key: ValueKey(data.data['id']),
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: Hero(
          tag: data.data['id'],
          child:CircleAvatar(
            backgroundImage: NetworkImage(data.data['image']),
          ),
        ),
        title: Text(data.data['name']),
        trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey),),
        onTap: mode==0?()=>_clicked(data):()async{
          DocumentSnapshot doc = await cu.currentUser.club.enterLikedClub(data.data['id']);
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => ClubPage(data: doc),
            )
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                ),
                accountName: Text(cu.currentUser.getDisplayName()),
                accountEmail: Text(cu.currentUser.getEmail()),
              ),
              cu.currentUser.getAdmin()==true?ListTile(
                leading: Icon(Icons.settings_applications),
                title: Text("관리자 설정"),
                onTap: (){
                  Navigator.pushNamed(context, '/appSetting');
                },
              ):SizedBox(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("설정"),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/personal');
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline),
                title: Text("다른 아이디로 로그인"),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                  cu.currentUser.googleLogOut();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon:Icon(Icons.menu),
            onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
          ),
          centerTitle: true,
          title: Text("동아리"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.fiber_new)),
              Tab(icon: Icon(Icons.favorite)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.pushNamed(context, '/new');
          },
        ),
        body: TabBarView(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('clubs').limit(_load).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 16.0),
                  children: snapshot.data.documents.map((data) => _buildListItem(context, data,0)).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').limit(_load2).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return ListView(
                  controller: _scrollController2,
                  padding: const EdgeInsets.only(top: 16.0),
                  children: snapshot.data.documents.map((data) => _buildListItem(context, data,1)).toList(),
                );
              },
            ),
          ],
        )
      ),
    );
  }
}