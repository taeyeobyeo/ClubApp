import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:project_club2/global/currentUser.dart'as cu;

class NewClubPage extends StatefulWidget {
  _NewClubPageState createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _advertisement = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _type = TextEditingController();
  bool adv = true;
  File _image;

  @override
  void dispose() { 
    _name.dispose();
    _advertisement.dispose();
    _description.dispose();
    _type.dispose(); 
    super.dispose();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.settings)),
              Tab(icon: Icon(Icons.image)),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("새로운 동아리"),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text("Create"),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _image!=null?FileImage(_image):AssetImage('assets/images/default.jpg'),
                        ),
                        title: Text(_name.text),
                      ),
                      content: Container(
                        height: MediaQuery.of(context).size.height*5/6,
                        width: MediaQuery.of(context).size.width*5/6,
                        child: ListView(
                          children: <Widget>[
                            
                            ExpansionTile(
                              title: Text("동아리이름"),
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: _name,
                                    maxLength: 15,
                                    decoration: InputDecoration(
                                      hintText: "ex) 슬기짜기",
                                      helperText: "15자 이내로 입력해주세요"
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ExpansionTile(
                              title: Text("배경이미지"),
                              children: <Widget>[
                                _image!=null?Image.file(_image):Image.asset('assets/images/default.jpg'),
                              ],
                            ),
                            ExpansionTile(
                              title: Text("동아리 소개글"),
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: _description,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: "ex) 1995년에 전산전자공학부 학부생들과 기계공학과 학부생들이 모여 친목을 도모하는 동아리입니다.",
                                      helperText: "5줄 이내로 입력해주세요"
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text("동아리 홍보글"),
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: _advertisement,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: "ex) 모집일정: 12/15일까지\n전산전자공학부 유일의 친목동아리",
                                      helperText: "5줄 이내로 입력해주세요"
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text("리쿠르팅"),
                              trailing: Switch(
                                onChanged: (bool value) {
                                  setState(() {
                                    adv = value;
                                  });
                                },
                                value: adv,
                              ),
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("이 기능을 키면 동아리를 생성하는 즉시 리쿠르팅이 시작합니다."),
                                )
                              ],
                            ),
                            ExpansionTile(
                              title: Text("소속 대학교"),
                              children: <Widget>[
                                ListTile(
                                  title: TextField(
                                    maxLength: 15,
                                    maxLines: 1,
                                    controller: _type,
                                    decoration: InputDecoration(
                                      hintText: "ex) 한동대학교",
                                      helperText: "대학교명 이외의 이름으로 생성시 경고 없이 삭제될 수 있습니다."
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("취소"),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        ),
                        RaisedButton(
                          child: Text("생성", style: TextStyle(color: Colors.black),),
                          color: Theme.of(context).primaryColor,
                          onPressed: ()async{
                            //check
                            if(_name.text ==""){
                              showDialog(
                                context: context,
                                builder: (context){
                                  return SimpleDialog(
                                    title: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: _image!=null?FileImage(_image):AssetImage("assets/images/default.jpg"),
                                      ),
                                      title: Text("동아리 이름을 입력해주세요"),
                                    ),
                                    children: <Widget>[
                                      ButtonBar(
                                        children: <Widget>[
                                          FlatButton(
                                            child: Text("확인", style: TextStyle(color: Theme.of(context).primaryColor),),
                                            onPressed: ()=>Navigator.pop(context),
                                          )
                                        ],
                                      )
                                    ],
                                  );
                                }
                              );
                              return;
                            }
                            else{
                            //do
                              Navigator.popUntil(context, ModalRoute.withName('/home'));
                              String id = Uuid().v1();
                              String image;
                              if(_image != null){
                                StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('club/$id/background').putFile(_image);
                                image = await (await uploadTask.onComplete).ref.getDownloadURL();
                              }
                              else image = "https://firebasestorage.googleapis.com/v0/b/project-club-94ec2.appspot.com/o/default.jpg?alt=media&token=09e85930-b245-47f6-93aa-eb373804f709";
                              Firestore.instance.runTransaction((Transaction transaction){
                                Firestore.instance.collection('clubs').document(id).setData({
                                  "id": id,
                                  "name": _name.text,
                                  "description": _description.text,
                                  "image": image,
                                  "advertisement": _advertisement.text,
                                  "adv": adv,
                                  "type": _type.text,
                                  "created": DateTime.now(),
                                });
                                Firestore.instance.collection('clubs').document(id).collection('users').document(cu.currentUser.getUid()).setData({
                                  "id": cu.currentUser.getUid(),
                                  "email": cu.currentUser.getEmail(),
                                  "level": 3,
                                  "name": cu.currentUser.getDisplayName(),
                                  "phoneNumber":cu.currentUser.getPhoneNumber(),
                                  "photoUrl":cu.currentUser.getphotoUrl(),
                                });
                                Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').document(id).setData({
                                  "id": id,
                                  "image": image,
                                  "level":3,
                                  "name": _name.text,
                                  "type": _type.text
                                });
                              });
                            }
                          },
                        ),
                      ],
                    );
                  }
                );
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
            ),
            TabBarView(
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text("배경 이미지"),
                            title: Image(
                              image: _image!=null?FileImage(_image):AssetImage("assets/images/default.jpg"),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: ()=>getImage(),
                            ),
                          ),
                          ListTile(
                            leading: Text("동아리 이름"),
                            title: TextField(
                              controller: _name,
                              maxLines: 1,
                              maxLength: 15,
                              decoration: InputDecoration(
                                hintText: "ex) 슬기짜기",
                                helperText: "15자 이내로 입력해주세요"
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text("소속 대학교"),
                            title: TextField(
                              controller: _type,
                              maxLines: 1,
                              maxLength: 15,
                              decoration: InputDecoration(
                                hintText: "ex) 한동대학교",
                                helperText: "15자 이내로 입력해주세요"
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text("동아리 소개"),
                            title: TextField(
                              controller: _description,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: "ex) 1995년에 전산전자공학부 학부생들과 기계공학과 학부생들이 모여 친목을 도모하는 동아리입니다.",
                                helperText: "5줄 이내로 입력해주세요"
                              ),
                            ),
                          ),
                          SwitchListTile(
                            title: Text("활성화시 동아리 생성후 가입신청을 바로 받을 수 있습니다.",style: TextStyle(fontSize: 14.0,color: Colors.grey[600]),),
                            secondary: Text("리쿠르팅    "),
                            onChanged: (bool value) {
                              setState(() {
                                adv = value;
                              });
                            },
                            value: adv,
                          ),
                          ListTile(
                            leading: Text("동아리 홍보"),
                            title: TextField(
                              controller: _advertisement,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: "ex) 모집일정: 12/15일까지 전산전자공학부 유일의 친목동아리",
                                helperText: "5줄 이내로 입력해주세요"
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        color: Colors.white70,
                        child: NestedScrollView(
                          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                            return <Widget>[
                              SliverAppBar(
                                expandedHeight: MediaQuery.of(context).size.height /4,
                                pinned: true,
                                leading: IconButton(
                                  icon: Icon(Icons.menu),
                                  onPressed: (){},
                                ),
                                flexibleSpace: FlexibleSpaceBar(
                                  centerTitle: true,
                                  title: Text(_name.text),
                                  background: Container(
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: _image!=null?FileImage(_image):AssetImage("assets/images/default.jpg"), 
                                        fit:BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("미리보기"),
                                    onPressed: (){},
                                  ),
                                ],
                              ),
                            ];
                          },
                          body: ListView(
                            children: <Widget>[
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    ExpansionTile(
                                      initiallyExpanded: true,
                                      title: Text("동아리소개"),
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(30.0),
                                          child: Text(_description.text),
                                        ),
                                      ],
                                    ),
                                    ExpansionTile(
                                      initiallyExpanded: true,
                                      title: Text("가입하기"),
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text(_advertisement.text),
                                        ),
                                        ButtonBar(
                                          children: <Widget>[
                                            Text("리쿠르팅 ON/OFF"),
                                            Switch(
                                              onChanged: (bool value) {
                                                setState(() {
                                                  adv = value;
                                                });
                                              },
                                              value: adv,
                                            ),
                                            RaisedButton(
                                              child: Text("가입하기"),
                                              color: Theme.of(context).primaryColor,
                                              onPressed: adv?(){}:null,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    // Image.network(data.data['body']['image'][0]),
                                    ListTile(   
                                      leading: CircleAvatar(
                                        backgroundImage: AssetImage("assets/images/sample1.jpg"),
                                      ),
                                      title: Text("작성자"),
                                      subtitle: Text(DateTime.now().toString()),
                                      trailing: Text("비공개"),
                                    ),
                                    Container(
                                      height: 300.0,
                                      padding: EdgeInsets.symmetric(vertical: 4.0),
                                      child: FlatButton(
                                            child: SizedBox(
                                              height: 300.0,
                                              width: MediaQuery.of(context).size.width -8,
                                                child: Image(
                                                  image: AssetImage("assets/images/sample2.jpg"),
                                                  fit: BoxFit.cover,
                                                ),
                                            ),
                                            padding: EdgeInsets.all(0.0),
                                            onPressed: (){},
                                          ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.favorite, color: Colors.red,),
                                              onPressed: (){},
                                            ),
                                            Text("32"),
                                          ],
                                        ),
                                        FlatButton(
                                          child: Text("더보기", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                                          onPressed: (){},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    // Image.network(data.data['body']['image'][0]),
                                    ListTile(   
                                      leading: CircleAvatar(
                                        backgroundImage: AssetImage("assets/images/sample1.jpg"),
                                      ),
                                      title: Text("작성자"),
                                      subtitle: Text(DateTime.now().toString()),
                                      trailing: Text("비공개"),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: <Widget>[
                                          FlatButton(
                                            child: SizedBox(
                                              height: 300.0,
                                              width: MediaQuery.of(context).size.width/2-8,
                                              child: Image(
                                                image: AssetImage("assets/images/sample3.jpg"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(0.0),
                                            onPressed: (){
                                              // print("page1");
                                            },
                                          ),
                                          FlatButton(
                                            child: SizedBox(
                                              height: 300.0,
                                              width: MediaQuery.of(context).size.width/2-8,
                                              child: Image(
                                                image: AssetImage("assets/images/sample4.jpg"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(0.0),
                                            onPressed: (){},
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.favorite_border, color: Colors.red,),
                                              onPressed: (){},
                                            ),
                                            Text("13"),
                                          ],
                                        ),
                                        FlatButton(
                                          child: Text("더보기", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                                          onPressed: (){},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    // Image.network(data.data['body']['image'][0]),
                                    ListTile(   
                                      leading: CircleAvatar(
                                        backgroundImage: AssetImage("assets/images/sample1.jpg"),
                                      ),
                                      title: Text("작성자"),
                                      subtitle: Text(DateTime.now().toString()),
                                      trailing: Text("비공개"),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: <Widget>[
                                          FlatButton(
                                            child: SizedBox(
                                              height: 300.0,
                                              width: MediaQuery.of(context).size.width*2/3-8,
                                              child: Image(
                                                image: AssetImage("assets/images/sample5.jpg"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(0.0),
                                            onPressed: (){
                                            },
                                          ),
                                          Column(
                                            children: <Widget>[
                                              FlatButton(
                                                child: SizedBox(
                                                  height: 150.0,
                                                  width: MediaQuery.of(context).size.width/3-8,
                                                  child: Image(
                                                    image: AssetImage("assets/images/sample6.jpg"),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                padding: EdgeInsets.all(0.0),
                                                onPressed: (){},
                                              ),
                                              FlatButton(
                                                child: Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 150.0,
                                                      width: MediaQuery.of(context).size.width/3-8,
                                                      child: Image(
                                                        image: AssetImage("assets/images/sample7.jpg"),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.all(0.0),
                                                onPressed: (){
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.favorite_border, color: Colors.red,),
                                              onPressed: (){},
                                            ),
                                            Text("245"),
                                          ],
                                        ),
                                        FlatButton(
                                          child: Text("더보기", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                                          onPressed: (){},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] 
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}