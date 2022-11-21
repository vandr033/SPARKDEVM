// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application/HomePage.dart';
import 'package:flutter_application/community_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'blocs/application_bloc.dart';
import 'data/user_data.dart';

List<String> screens = ['Create Event', 'Create Community'];
String whenEventchosenScreen = 'Create Event';
String? chosenScreen = 'Create Community';
DateTime startDate = DateTime.now();
DateTime startTime = DateTime.now();
DateTime endDate = DateTime.now();
DateTime endTime = DateTime.now();
bool eventInfoVisible = false;
bool comInfoVisible = true;
int imageIndex = 0;

class EventScreen extends StatefulWidget {
  static String tag = 'event-screen';
  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  final eventPanelController = PanelController();

  var bottomNavVis = true;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final eventPanelHeightClosed = MediaQuery.of(context).size.height *
        0; //when we first come onto the page, panel will be 10% of our screen height - can modify if necessary.
    final eventPanelHeightOpen = MediaQuery.of(context).size.height *
        0.8; //if you scroll panel all the way up, it will occupy 80% of the screen - can modify if necessary.

    return Scaffold(
      body: SlidingUpPanel(
        onPanelClosed: () {
          setState(() {
            bottomNavVis = true;
          });
        },
        onPanelOpened: () {
          setState(() {
            bottomNavVis = false;
          });
        },
        backdropEnabled: true,
        controller: eventPanelController,
        maxHeight: eventPanelHeightOpen, //max height of panel
        minHeight:
            eventPanelHeightClosed, //min height of panel - can adjust if need be
        body: Center(
          //this is our background. (body within body:SlidingUpPanel is our background, aka what's behind the panel.)
          child: Text(
              "Event Screen"), //this is just here for demonstrative purposes - this is the widget behind the sliding panel - therefore this is wrapped within the sliding up panel - it is our background.
        ),
        panelBuilder: (controller) => PanelWidget(
          comPanelController: eventPanelController,
          eventController: controller,
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)), //rounded corners
      ),
      bottomNavigationBar: Visibility(
        visible: bottomNavVis,
        maintainState: true,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Color.fromRGBO(63, 63, 63, 1),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    eventPanelController.close();
                    index = 0;
                  });
                },
                icon: Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    eventPanelController.close();
                    index = 1;
                  });
                },
                icon: Icon(
                  Icons.search_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    index = 2;
                    eventPanelController.open();
                  });
                },
                icon: Icon(
                  Icons.add_box_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    eventPanelController.close();
                    index = 3;
                  });
                },
                icon: Icon(
                  Icons.chat_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    eventPanelController.close();
                    index = 4;
                  });
                },
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanelWidget extends StatefulWidget {
  final ScrollController eventController;
  final PanelController comPanelController;

  PanelWidget({
    Key? key,
    required this.eventController,
    required this.comPanelController,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  /*
  Drop down 
  */
  String? _eventSelected;
  String? _comSelected;
  List<Map> _comunJson = [
    {
      'id': '1',
      'image': 'assets/category_logos/sports_logo.png',
      'name': 'Sports'
    },
    {
      'id': '2',
      'image': 'assets/category_logos/travel_logo.png',
      'name': 'Travel'
    },
    {
      'id': '3',
      'image': 'assets/category_logos/music_logo.png',
      'name': 'Music'
    },
    {
      'id': '4',
      'image': 'assets/category_logos/school_logo.png',
      'name': 'School'
    },
  ];
  List<Map> _eventJson = [
    {
      'id': '1',
      'image': 'assets/community_logos/hamburger_logo.png',
      'name': 'Foodies'
    },
    {
      'id': '2',
      'image': 'assets/community_logos/globe_trotters_logo.png',
      'name': 'Globetrotters'
    },
    {
      'id': '3',
      'image': 'assets/community_logos/musicians_logo.png',
      'name': 'Musicians'
    },
    {
      'id': '4',
      'image': 'assets/community_logos/einsteins_logo.png',
      'name': 'Einsteins'
    },
  ];

  /*
  Image picker 
  */
  File? communityImage1;
  File? communityImage2;
  File? eventImage1;
  File? eventImage2;
  File? eventImage3;
  File? eventImage4;

  var dropdownValue;

  String eventHostName = '';
  String communityHostName = '';
  bool eventExistsHost = false;
  bool communityExistsHost = false;

  String locationName = '';
  bool locationVisible = false;

  bool selected = false;
  Future communityPickImage1() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() => communityImage1 = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  Future pickImage2() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() => communityImage2 = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  Future eventPickImage1() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() {
        eventImage1 = imageTemp;
        imageIndex = 1;
      });
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  Future eventPickImage2() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() {
        setState(() {
          eventImage2 = imageTemp;
          imageIndex = 2;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  Future eventPickImage3() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() {
        setState(() {
          eventImage3 = imageTemp;
          imageIndex = 3;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  Future eventPickImage4() async {
    try {
      final imageGrab =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (imageGrab == null) return;

      final imageTemp = File(imageGrab.path);

      setState(() => eventImage4 = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to get image: $e');
    }
  }

  void eventStartDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (val) {
                          setState(() {
                            startDate = val;
                          });
                        }),
                  ),
                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => {
                      Navigator.of(ctx, rootNavigator: true).pop(ctx),
                    },
                  )
                ],
              ),
            ));
  }

  void eventStartTimePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        mode: CupertinoDatePickerMode.time,
                        onDateTimeChanged: (val) {
                          setState(() {
                            startTime = val;
                          });
                        }),
                  ),
                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => {
                      Navigator.of(ctx, rootNavigator: true).pop(ctx),
                    },
                  )
                ],
              ),
            ));
  }

  void eventEndDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (val) {
                          setState(() {
                            endDate = val;
                          });
                        }),
                  ),
                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => {
                      Navigator.of(ctx, rootNavigator: true).pop(ctx),
                    },
                  )
                ],
              ),
            ));
  }

  void eventEndTimePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        mode: CupertinoDatePickerMode.time,
                        onDateTimeChanged: (val) {
                          setState(() {
                            endTime = val;
                          });
                        }),
                  ),
                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => {
                      Navigator.of(ctx, rootNavigator: true).pop(ctx),
                    },
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) => ListView(
        //ListView is a scrollable list of widgets arranged linearly.
        padding: EdgeInsets.zero,
        controller: widget.eventController,
        children: <Widget>[
          SizedBox(height: 12),
          buildDragHandle(),
          SizedBox(height: 30),
          buildEventInfo(), //widget below.
          buildCommunityInfo(),
          SizedBox(height: 30),
        ],
      );

  Widget buildEventInfo() {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Visibility(
      visible: eventInfoVisible,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    flex: 6, // default
                    child: Container(
                      // required field
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0XFFD7D9D7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      width: 226,
                      height: 46,

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12.0),
                          dropdownColor: Color(0XFFD7D9D7),
                          style: const TextStyle(
                              color: Colors.white, //<-- SEE HERE
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          value: whenEventchosenScreen,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white, // <-- SEE HERE
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != dropdownValue) {
                              switch (newValue) {
                                case 'Create Event':
                                  //Navigator.of(context).push(MaterialPageRoute(
                                  //builder: (context) => EventScreen()));
                                  break;
                                case 'Create Community':
                                  //Navigator.of(context).push(MaterialPageRoute(
                                  //  builder: (context) => CommunityScreen()));
                                  setState(() {
                                    eventInfoVisible = false;
                                    comInfoVisible = true;
                                  });
                                  break;
                              }
                            }
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>['Create Event', 'Create Community']
                              .map<DropdownMenuItem<String>>(
                                  (String chosenScreen) {
                            return DropdownMenuItem<String>(
                              value: chosenScreen,
                              child: Text(
                                chosenScreen,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 0, // default
                  child: Container(
                    width: 20,
                  ), // required field
                ),
                Expanded(
                  flex: 4, // default
                  child: Container(
                    width: 114,
                    height: 46,
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        hintText: "Name",
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Color(0XFFD7D9D7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        alignLabelWithHint: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            Container(
              //this contains our image picker
              height: 184,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    elevation: 8.0,
                    child: Container(
                        height: 184,
                        width: 108,
                        decoration: eventImage1 != null
                            ? BoxDecoration(
                                color: Color(0xffD7D9D7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: FileImage(eventImage1!),
                                    fit: BoxFit.fill))
                            : BoxDecoration(
                                color: Color(0xffD7D9D7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                        child: eventImage1 != null
                            ? Icon(null)
                            : Icon(Icons.upload_rounded, color: Colors.white)),
                    onPressed: () {
                      if (eventImage1 != null) {
                        setState(() {
                          eventImage1 = eventImage2;
                          eventImage2 = eventImage3;
                          eventImage3 = eventImage4;
                          eventImage4 = null;
                          imageIndex = imageIndex - 1;
                        });
                      } else {
                        if (imageIndex == 0) {
                          eventPickImage1();
                        }
                      }
                    },
                  ),
                  MaterialButton(
                    elevation: 8.0,
                    child: Container(
                        height: 184,
                        width: 108,
                        decoration: eventImage2 != null
                            ? BoxDecoration(
                                color: Color(0xffD7D9D7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: FileImage(eventImage2!),
                                    fit: BoxFit.fill))
                            : imageIndex == 1
                                ? BoxDecoration(
                                    color: Color(0xffD7D9D7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)))
                                : BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                        child: eventImage2 != null
                            ? Icon(null)
                            : Icon(Icons.upload_rounded, color: Colors.white)),
                    onPressed: () {
                      if (eventImage2 != null) {
                        setState(() {
                          eventImage2 = eventImage3;
                          eventImage3 = eventImage4;
                          eventImage4 = null;
                          imageIndex = imageIndex - 1;
                        });
                      } else {
                        if (imageIndex == 1) {
                          eventPickImage2();
                        }
                      }
                    },
                  ),
                  MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    elevation: 8.0,
                    child: Container(
                        height: 184,
                        width: 108,
                        decoration: eventImage3 != null
                            ? BoxDecoration(
                                color: Color(0xffD7D9D7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: FileImage(eventImage3!),
                                    fit: BoxFit.fill))
                            : imageIndex == 2
                                ? BoxDecoration(
                                    color: Color(0xffD7D9D7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)))
                                : BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                        child: eventImage3 != null
                            ? Icon(null)
                            : Icon(Icons.upload_rounded, color: Colors.white)),
                    onPressed: () {
                      if (eventImage3 != null) {
                        setState(() {
                          eventImage3 = eventImage4;
                          eventImage4 = null;
                          imageIndex = imageIndex - 1;
                        });
                      } else {
                        if (imageIndex == 2) {
                          eventPickImage3();
                        }
                      }
                    },
                  ),
                  MaterialButton(
                    elevation: 8.0,
                    child: Container(
                        height: 184,
                        width: 108,
                        decoration: eventImage4 != null
                            ? BoxDecoration(
                                color: Color(0xffD7D9D7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: FileImage(eventImage4!),
                                    fit: BoxFit.fill))
                            : imageIndex == 3
                                ? BoxDecoration(
                                    color: Color(0xffD7D9D7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)))
                                : BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                        child: eventImage4 != null
                            ? Icon(null)
                            : Icon(Icons.upload_rounded, color: Colors.white)),
                    onPressed: () {
                      if (eventImage4 != null) {
                        setState(() {
                          eventImage4 = null;
                          imageIndex = 2;
                        });
                      } else {
                        if (imageIndex == 3) {
                          eventPickImage4();
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 15),

            //Event start
/*
              Google Places dropdown here. 
              */

            Row(
              //example
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 360,
                    height: 46,
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                          //hintText: 'Add Location',
                          filled: true,
                          fillColor: Color(0XFFD7D9D7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          alignLabelWithHint: false,
                          //labelText: 'Add Location:',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                      onChanged: (value) {
                        setState(() {
                          selected = false;
                        });
                        applicationBloc.searchPlaces(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            /*
            TextField(
              style: TextStyle(
                color: Colors.white,
              ),
              obscureText: false,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: 'Add Location',
                filled: true,
                fillColor: Color(0XFFD7D9D7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                alignLabelWithHint: false,
                //labelText: '  Description:',
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selected = false;
                });
                applicationBloc.searchPlaces(value);
              },
            ),*/

            /*
            TextField(
              decoration: InputDecoration(hintText: 'Add Location'),
              onChanged: (value) {
                setState(() {
                  selected = false;
                });
                applicationBloc.searchPlaces(value);
              },
            ),*/

            if (applicationBloc.searchResults != null &&
                applicationBloc.searchResults?.length != 0 &&
                selected == false)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                  color: Color(0xffD7D9D7),
                ),
                height: 300,
                child: ListView.builder(
                  itemCount: applicationBloc.searchResults!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        onTap: () {
                          setState(() {
                            selected = true;
                            locationVisible = true;
                            locationName = applicationBloc
                                .searchResults![index].description;
                          });
                        },
                        title: Text(
                            applicationBloc.searchResults![index].description,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700)));
                  },
                ),
              ),

            Visibility(
                visible: locationVisible,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                          side: BorderSide(color: Color(0xff4589FF)))),
                  onPressed: () {
                    setState(() {
                      locationVisible = false;
                      locationName = '';
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(locationName),
                      Icon(
                        Icons.close,
                        color: Colors.grey,
                      )
                    ],
                  ),
                )),
            SizedBox(height:15),
            Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 363,
                    height: 50.0,
                    child: Card(
                      color: Color(0XFFD7D9D7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                              width: 115,
                              height: 15,
                              child: Text(
                                "Event starts: ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              )),
                          //spacing between eve start and white boxes
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 95,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () =>
                                  eventStartDatePicker(this.context),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              child: Text(
                                startDate != null
                                    ? DateFormat.yMMMd().format(startDate)
                                    : 'No Date!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: false,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () =>
                                  eventStartTimePicker(this.context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              child: Text(
                                startDate != null
                                    ? DateFormat.jm().format(startTime)
                                    : 'No Time!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: false,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height:10),

            Row(
              //mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    //width: 363,
                    height: 50.0,
                    child: Card(
                      color: Color(0XFFD7D9D7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                              width: 115,
                              height: 15,
                              child: Text(
                                "Event ends: ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 95,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => eventEndDatePicker(this.context),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              child: Text(
                                endDate != null
                                    ? DateFormat.yMMMd().format(endDate)
                                    : 'No Date!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: false,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => eventEndTimePicker(this.context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              child: Text(
                                endTime != null
                                    ? DateFormat.jm().format(endTime)
                                    : 'No Time!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: false,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 15),

            //this is where host goes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //this contains our host drop down.
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 360,
                    height: 55,
                    //color: Color(0xffD7D9D7),
                    padding: EdgeInsets.all(1),
                    // decoration: BoxDecoration(
                    //   color: Color(0xffD7D9D7),
                    //   borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: TypeAheadField<User?>(
                      //Here we use <User> because that is what we are autocompleting for.
                      direction: AxisDirection.up,
                      hideOnEmpty: true,
                      //TypeAheadField - A TextField that displays a list of suggestions as the user types.
                      //hideSuggestionsOnKeyboardHide: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                          ),
                          hintText: 'Hosts: ',
                          hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          filled: true,
                          fillColor: Color(0xffD7D9D7),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        color: Color(0xffD7D9D7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suggestionsCallback: UserData
                          .getSuggestions, //we get suggestions from UserData
                      itemBuilder: (context, User? suggestion) {
                        final user = suggestion!;

                        return ListTile(
                          leading: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(user.imageUrl),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          title: Text(user.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        );
                      },
                      noItemsFoundBuilder: (context) => Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'No Users Found.',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      onSuggestionSelected: (User? suggestion) {
                        final user = suggestion!;
                        setState(() {
                          eventHostName = user.name;
                          eventExistsHost = true;
                        });

                        //the suggestion that we selected is stored in user variable.

                        //Container(height: 20, width: 20, Text(name));

                        //this is the part where we say what we want to do in the selection... aka we need to put it in a container.

                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => UserDetailPage(user: user)
                      }
                      /*
                          Container(height:20, width:20,
                          Text(suggestion.name;)*/

                      //this is the part where we say what we want to do in the selection... aka we need to put it in a container.
                      /*
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserDetailPage(user: user)
                        )
                        );*/
                      ,
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
                visible: eventExistsHost,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                          side: BorderSide(color: Color(0xff4589FF)))),
                  onPressed: () {
                    setState(() {
                      eventExistsHost = false;
                      eventHostName = '';
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(eventHostName),
                      Icon(
                        Icons.close,
                        color: Colors.grey,
                      )
                    ],
                  ),
                )),
            SizedBox(height: 10),

            /*
            Row(
              //example
              children: [
                Expanded(
                    flex: 1, // default
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0XFFD7D9D7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      width: 360,
                      height: 46,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12.0),
                          dropdownColor: Color(0XFFD7D9D7),
                          style: const TextStyle(
                              color: Colors.white, //<-- SEE HERE
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white, // <-- SEE HERE
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>['Car', 'Train', 'Bus', 'Flight']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ) // required field
                    ),
              ],
            ),*/

            Row(
              children: [
                Expanded(
                    flex: 1, // default
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0XFFD7D9D7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      width: 360,
                      height: 46,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text('Select Community',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12.0),
                          dropdownColor: Color(0XFFD7D9D7),
                          style: const TextStyle(
                              color: Colors.white, //<-- SEE HERE
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white, // <-- SEE HERE
                          ),
                          value: _eventSelected,
                          onChanged: (newValue) {
                            setState(() {
                              _eventSelected = newValue;
                            });
                          },
                          items: _eventJson.map(
                            (categoryItem) {
                              return DropdownMenuItem(
                                value: categoryItem['id'].toString(),
                                child: Row(
                                  children: [
                                    Image.asset(categoryItem['image'],
                                        width: 30),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(categoryItem['name']))
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ) // required field
                    ),
              ],
            ),

            SizedBox(height: 20),

            //Post Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 250.0,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff4589FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0))),
                        child: const Text(
                          'Post',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///COMMUNITY!
  //////////////////////////////////////////////////////////////////

  Widget buildCommunityInfo() => Visibility(
        visible: comInfoVisible,
        child: Container(
          //here i have created a container with a child column - you can fill the column will all of the rows and its children, or anything else, that you need.
          //this is all the stuff in our panel.

          padding: EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                //example
                children: [
                  Expanded(
                      flex: 6, // default
                      child: Container(
                        // required field
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0XFFD7D9D7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        width: 226,
                        height: 46,

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(12.0),
                            dropdownColor: Color(0XFFD7D9D7),
                            style: const TextStyle(
                                color: Colors.white, //<-- SEE HERE
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            value: chosenScreen,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white, // <-- SEE HERE
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != dropdownValue) {
                                switch (newValue) {
                                  case 'Create Community':
                                    //Navigator.of(context).push(MaterialPageRoute(
                                    //builder: (context) => CommunityScreen()));
                                    break;
                                  case 'Create Event':
                                    setState(() {
                                      eventInfoVisible = true;
                                      comInfoVisible = false;
                                    });
                                    break;
                                }
                              }
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: <String>['Create Community', 'Create Event']
                                .map<DropdownMenuItem<String>>(
                                    (String chosenScreen) {
                              return DropdownMenuItem<String>(
                                value: chosenScreen,
                                child: Text(
                                  chosenScreen,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                  Expanded(
                    flex: 0, // default
                    child: Container(
                      width: 20,
                    ), // required field
                  ),
                  Expanded(
                    flex: 4, // default
                    child: Container(
                      width: 114,
                      height: 46,
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        obscureText: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          hintText: "Name",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Color(0XFFD7D9D7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          alignLabelWithHint: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Stack(
                //Row(
                //example
                children: [
                  //Image Picker
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      elevation: 8.0,
                      child: Container(
                          alignment: Alignment(.90, -.75),
                          height: 110,
                          width: 360,
                          decoration: communityImage1 != null
                              ? BoxDecoration(
                                  color: Color(0xffD7D9D7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  image: DecorationImage(
                                      image: FileImage(communityImage1!),
                                      fit: BoxFit.fill))
                              : BoxDecoration(
                                  color: Color(0xffD7D9D7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                          child: communityImage1 != null
                              ? Icon(null)
                              : Icon(Icons.upload_rounded,
                                  color: Colors.white)),
                      onPressed: () {
                        communityPickImage1();
                      },
                    ),
                  ),

                  //white buffer between the circle image and rectangle immage
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),

                  //Circle stacked ontop
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 65, 0, 0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 75,
                          width: 75,
                          decoration: communityImage2 != null
                              ? BoxDecoration(
                                  color: Color(0xffD7D9D7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  image: DecorationImage(
                                      image: FileImage(communityImage2!),
                                      fit: BoxFit.fill))
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffD7D9D7),
                                ),
                          child: communityImage2 != null
                              ? Icon(null)
                              : Icon(Icons.upload_rounded,
                                  color: Colors.white)),
                    ),
                  ),
                ],
                //),
              ),

              SizedBox(height: 10),

              Stack(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 360,
                      height: 46,
                      decoration: BoxDecoration(
                        //color: Colors.green,
                        color: Color(0xffD7D9D7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Icon(
                        Icons.check,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 360,
                      height: 46,
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        obscureText: false,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.shield_outlined,
                              size: 1,
                            ),
                            hintText: 'Community Guidelines:',
                            filled: false,
                            fillColor: Color(0XFFD7D9D7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            alignLabelWithHint: false,
                            labelText: '  Community Guidelines:',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              //this is where host goes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //this contains our host drop down.
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 360,
                      height: 55,
                      //color: Color(0xffD7D9D7),
                      padding: EdgeInsets.all(1),
                      // decoration: BoxDecoration(
                      //   color: Color(0xffD7D9D7),
                      //   borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: TypeAheadField<User?>(
                        //Here we use <User> because that is what we are autocompleting for.
                        hideOnEmpty: true,
                        //TypeAheadField - A TextField that displays a list of suggestions as the user types.
                        //hideSuggestionsOnKeyboardHide: false,
                        direction: AxisDirection.up,
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.search, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            hintText: 'Hosts: ',
                            hintStyle: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            filled: true,
                            fillColor: Color(0xffD7D9D7),
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          color: Color(0xffD7D9D7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suggestionsCallback: UserData
                            .getSuggestions, //we get suggestions from UserData
                        itemBuilder: (context, User? suggestion) {
                          final user = suggestion!;

                          return ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(user.imageUrl),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            title: Text(user.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          );
                        },
                        noItemsFoundBuilder: (context) => Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'No Users Found.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        onSuggestionSelected: (User? suggestion) {
                          final user = suggestion!;

                          setState(() {
                            communityHostName = user.name;
                            communityExistsHost = true;
                          });
                          //the suggestion that we selected is stored in user variable.

                          //Container(height: 20, width: 20, Text(name));

                          //this is the part where we say what we want to do in the selection... aka we need to put it in a container.

                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => UserDetailPage(user: user)
                        }
                        /*
                          Container(height:20, width:20,
                          Text(suggestion.name;)*/

                        //this is the part where we say what we want to do in the selection... aka we need to put it in a container.
                        /*
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserDetailPage(user: user)
                        )
                        );*/
                        ,
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: communityExistsHost,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: BorderSide(color: Color(0xff4589FF)))),
                    onPressed: () {
                      setState(() {
                        communityExistsHost = false;
                        communityHostName = '';
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(communityHostName),
                        Icon(
                          Icons.close,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  )),
              SizedBox(height: 10),
              //SizedBox(height: 10),

              Row(
                //example
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 360,
                      height: 46,
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        obscureText: false,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: 'Description:',
                            filled: true,
                            fillColor: Color(0XFFD7D9D7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            alignLabelWithHint: false,
                            labelText: '  Description:',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                      flex: 1, // default
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0XFFD7D9D7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        width: 360,
                        height: 46,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text('Select Category',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(12.0),
                            dropdownColor: Color(0XFFD7D9D7),
                            style: const TextStyle(
                                color: Colors.white, //<-- SEE HERE
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white, // <-- SEE HERE
                            ),
                            value: _comSelected,
                            onChanged: (newValue) {
                              setState(() {
                                _comSelected = newValue;
                              });
                            },
                            items: _comunJson.map(
                              (categoryItem) {
                                return DropdownMenuItem(
                                  value: categoryItem['id'].toString(),
                                  child: Row(
                                    children: [
                                      Image.asset(categoryItem['image'],
                                          width: 30),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(categoryItem['name']))
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ) // required field
                      ),
                ],
              ),

              SizedBox(height: 20),

              //Post Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 250.0,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff4589FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0))),
                        child: const Text(
                          'Post',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  Widget buildDragHandle() => GestureDetector(
        child: Center(
          child: Container(
            width: 100,
            height: 3,
            decoration: BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onTap: togglePanel,
      );

  void togglePanel() => widget.comPanelController
          .isPanelOpen //this is working, but you have to click exactly on the skinny gray line for it to work... i wonder how this would translate to using the app on a real phone, hopefully would not be a problem.
      ? widget.comPanelController.close()
      : widget.comPanelController.open();
}
