import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/screens/notification_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../controller/data_controller.dart';
import '../../../widgets/my_widgets.dart';
import '../Model/event_model.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  DateTime? date = DateTime.now();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController maxEntries = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController frequencyEventController = TextEditingController();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);

  var selectedFrequency = -2;

  void resetControllers() {
    dateController.clear();
    timeController.clear();
    titleController.clear();
    locationController.clear();
    priceController.clear();
    descriptionController.clear();
    tagsController.clear();
    maxEntries.clear();
    endTimeController.clear();
    startTimeController.clear();
    frequencyEventController.clear();
    startTime = const TimeOfDay(hour: 0, minute: 0);
    endTime = const TimeOfDay(hour: 0, minute: 0);
    setState(() {});
  }
  void publishEvent() async {
    // After publishing, notify users
    String? userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user ID

    if (userId != null) {
      await LocalNotificationService.storeNotification(
        title: 'New Event Published!',
        body: 'A new event has been published. Check it out!',
        userId: userId, // Use the current user's ID
      );
    } else {
      print('No user is currently signed in.');
    }
  }

  var isCreatingEvent = false.obs;

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      date = DateTime(picked.year, picked.month, picked.day, date!.hour,
          date!.minute, date!.second);
      dateController.text = '${date!.day}-${date!.month}-${date!.year}';
    }
    setState(() {});
  }

  startTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      startTime = picked;
      startTimeController.text =
          '${startTime.hourOfPeriod > 9 ? "" : '0'}${startTime.hour > 12 ? '${startTime.hour - 12}' : startTime.hour}:${startTime.minute > 9 ? startTime.minute : '0${startTime.minute}'} ${startTime.hour > 12 ? 'PM' : 'AM'}';
    }
    print("start ${startTimeController.text}");
    setState(() {});
  }

  endTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      endTime = picked;
      endTimeController.text =
          '${endTime.hourOfPeriod > 9 ? "" : "0"}${endTime.hour > 9 ? "" : "0"}${endTime.hour > 12 ? '${endTime.hour - 12}' : endTime.hour}:${endTime.minute > 9 ? endTime.minute : '0${endTime.minute}'} ${endTime.hour > 12 ? 'PM' : 'AM'}';
    }

    print(endTime.hourOfPeriod);
    setState(() {});
  }

  String event_type = 'Public';
  List<String> list_item = ['Public', 'Private'];

  String accessModifier = 'Closed';
  List<String> close_list = [
    'Closed',
    'Open',
  ];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> mediaUrls = [];

  List<EventMediaModel> media = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeController.text = '${date!.hour}:${date!.minute}:${date!.second}';
    dateController.text = '${date!.day}-${date!.month}-${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        title: const Text('Create Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0, // Remove AppBar shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                //iconWithTitle(text: 'Create Event', func: () {}),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: 90,
                      height: 33,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.black.withOpacity(0.6),
                                  width: 0.6))),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     width: 0,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            ),

                        // borderRadius: BorderRadius.circular(10),
                        icon: Image.asset('lib/assets/arrowDown.png'),
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                        value: event_type,
                        onChanged: (String? newValue) {
                          setState(
                            () {
                              event_type = newValue!;
                            },
                          );
                        },
                        items: list_item
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                Container(
                  height: Get.width * 0.6,
                  width: Get.width * 0.9,
                  decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: DottedBorder(
                    color: AppColors.border,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 6],
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Get.height * 0.05,
                          ),
                          SizedBox(
                            width: 76,
                            height: 59,
                            child: Image.asset('lib/assets/uploadIcon.png'),
                          ),
                          myText(
                            text: 'Click and upload image/video',
                            style: TextStyle(
                              color: AppColors.lightGreen,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          elevatedButton(
                              onpress: () async {
                                mediaDialog(context);
                              },
                              text: 'Upload')
                        ],
                      ),
                    ),
                  ),
                ),
                // This widget checks if media is empty and conditionally displays the media uploader or a message
                media.isEmpty
                    ? Container(
                  // You can provide a message here or leave it empty
                  child: const Text("No media uploaded. You can upload images or videos."),
                )
                    : const SizedBox(height: 20), // Spacing when media is present

                media.isEmpty
                    ? Container() // No media, do nothing
                    : SizedBox(
                  width: Get.width,
                  height: Get.width * 0.3,
                  child: ListView.builder(
                    itemBuilder: (ctx, i) {
                      // If the media item is a video
                      return media[i].isVideo!
                          ? Container(
                        width: Get.width * 0.3,
                        height: Get.width * 0.3,
                        margin: const EdgeInsets.only(
                            right: 15, bottom: 10, top: 10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(media[i].thumbnail!),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    child: IconButton(
                                      onPressed: () {
                                        media.removeAt(i);
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.slow_motion_video_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            )
                          ],
                        ),
                      )
                      // If the media item is an image
                          : Container(
                        width: Get.width * 0.3,
                        height: Get.width * 0.3,
                        margin: const EdgeInsets.only(
                            right: 15, bottom: 10, top: 10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(media[i].image!),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: CircleAvatar(
                                child: IconButton(
                                  onPressed: () {
                                    media.removeAt(i);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: media.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                myTextField(
                    bool: false,
                    icon: 'lib/assets/4DotIcon.png',
                    text: 'Event Name',
                    controller: titleController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Opps', "Event name is required.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }

                      if (input.length < 3) {
                        Get.snackbar(
                            'Opps', "Event name is should be 3+ characters.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),

                const SizedBox(
                  height: 20,
                ),
                myTextField(
                    bool: false,
                    icon: 'lib/assets/location.png',
                    text: 'Location',
                    controller: locationController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Opps', "Location is required.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }

                      if (input.length < 3) {
                        Get.snackbar('Opps', "Location is Invalid.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconTitleContainer(
                      isReadOnly: true,
                      path: 'lib/assets/Frame1.png',
                      text: 'Date',
                      controller: dateController,
                      validator: (input) {
                        if (date == null) {
                          Get.snackbar('Opps', "Date is required.",
                              colorText: Colors.white,
                              backgroundColor: Colors.blue);
                          return '';
                        }
                        return null;
                      },
                      onPress: () {
                        _selectDate(context);
                      },
                    ),
                    iconTitleContainer(
                        path: 'lib/assets/#.png',
                        text: 'Max Entries',
                        controller: maxEntries,
                        type: TextInputType.number,
                        onPress: () {},
                        validator: (String input) {
                          if (input.isEmpty) {
                            Get.snackbar('Opps', "Entries is required.",
                                colorText: Colors.white,
                                backgroundColor: Colors.blue);
                            return '';
                          }
                          return null;
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                iconTitleContainer(
                    path: 'lib/assets/#.png',
                    text: 'Enter tags that will go with event.',
                    width: double.infinity,
                    controller: tagsController,
                    type: TextInputType.text,
                    onPress: () {},
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Opps', "Entries is required.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(width: 1, color: AppColors.genderTextColor),
                  ),
                  child: TextFormField(
                    readOnly: true,
                    onTap: () {
                      Get.bottomSheet(StatefulBuilder(builder: (ctx, state) {
                        return Container(
                          width: double.infinity,
                          height: Get.width * 0.6,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceAround,
                                children: [
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 5,
                                        ),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      selectedFrequency = -1;

                                      state(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selectedFrequency == -1
                                            ? Colors.blue
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Once",
                                          style: TextStyle(
                                              color: selectedFrequency != -1
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 5,
                                        ),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      selectedFrequency = 0;

                                      state(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selectedFrequency == 0
                                            ? Colors.blue
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Daily",
                                          style: TextStyle(
                                              color: selectedFrequency != 0
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 10,
                                        ),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      state(() {
                                        selectedFrequency = 1;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: selectedFrequency == 1
                                            ? Colors.blue
                                            : Colors.black.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Weekly",
                                          style: TextStyle(
                                              color: selectedFrequency != 1
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 10,
                                        ),
                                ],
                              ),
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceAround,
                                children: [
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 10,
                                        ),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      state(() {
                                        selectedFrequency = 2;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: selectedFrequency == 2
                                            ? Colors.blue
                                            : Colors.black.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Monthly",
                                          style: TextStyle(
                                              color: selectedFrequency != 2
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 10,
                                        ),
                                  Expanded(
                                      child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: selectedFrequency == 3
                                            ? Colors.blue
                                            : Colors.black.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Yearly",
                                          style: TextStyle(
                                              color: selectedFrequency != 3
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      state(() {
                                        selectedFrequency = 3;
                                      });
                                    },
                                  )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : const SizedBox(
                                          width: 5,
                                        ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    minWidth: Get.width * 0.8,
                                    onPressed: () {
                                      frequencyEventController.text =
                                          selectedFrequency == -1
                                              ? 'Once'
                                              : selectedFrequency == 0
                                                  ? 'Daily'
                                                  : selectedFrequency == 1
                                                      ? 'Weekly'
                                                      : selectedFrequency == 2
                                                          ? 'Monthly'
                                                          : 'Yearly';
                                      Get.back();
                                    },
                                    color: Colors.blue,
                                    child: const Text(
                                      "Select",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }));
                    },
                    validator: (String? input) {
                      if (input!.isEmpty) {
                        Get.snackbar('Opps', "Frequency is required.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    },
                    controller: frequencyEventController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 3),
                      errorStyle: const TextStyle(fontSize: 0),
                      hintStyle: TextStyle(
                        color: AppColors.genderTextColor,
                      ),
                      border: InputBorder.none,
                      hintText: 'Frequency of event',
                      prefixIcon: Image.asset(
                        'lib/assets/repeat.png',
                        cacheHeight: 20,
                      ),
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),

                // myTextField(
                //     bool: false,
                //     icon: 'assets/repeat.png',
                //     text: 'Frequecy of event',
                //     controller: frequencyEventController,
                //     validator: (String input){
                //       if(input.isEmpty){
                //         Get.snackbar('Opps', "Frequency is required.",colorText: Colors.white,backgroundColor: Colors.blue);
                //         return '';
                //       }
                //     }
                // ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconTitleContainer(
                        path: 'lib/assets/time.png',
                        text: 'Start Time',
                        controller: startTimeController,
                        isReadOnly: true,
                        validator: (input) {},
                        onPress: () {
                          startTimeMethod(context);
                        }),
                    iconTitleContainer(
                        path: 'lib/assets/time.png',
                        text: 'End Time',
                        isReadOnly: true,
                        controller: endTimeController,
                        validator: (input) {},
                        onPress: () {
                          endTimeMethod(context);
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    myText(
                        text: 'Description/Instruction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 149,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(width: 1, color: AppColors.genderTextColor),
                  ),
                  child: TextFormField(
                    maxLines: 5,
                    controller: descriptionController,
                    validator: (input) {
                      if (input!.isEmpty) {
                        Get.snackbar('Opps', "Description is required.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.only(top: 25, left: 15, right: 15),
                      hintStyle: TextStyle(
                        color: AppColors.genderTextColor,
                      ),
                      hintText:
                          'Write a summary and any details your invitee should know about the event...',
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(8.0),
                      // ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: myText(
                    text: 'Who can invite?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.005,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            width: 1, color: AppColors.genderTextColor),
                      ),
                      // decoration: BoxDecoration(
                      //
                      //   // borderRadius: BorderRadius.circular(8),
                      //    border: Border(
                      //         bottom: BorderSide(color: Colors.black.withOpacity(0.8),width: 0.6)
                      //     )
                      //
                      // ),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Container(),
                        //borderRadius: BorderRadius.circular(10),
                        icon: Image.asset('lib/assets/arrowDown.png'),
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                        value: accessModifier,
                        onChanged: (String? newValue) {
                          setState(
                            () {
                              accessModifier = newValue!;
                            },
                          );
                        },
                        items: close_list
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffA6A6A6),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    iconTitleContainer(
                        path: 'lib/assets/dollarLogo.png',
                        text: 'price',
                        type: TextInputType.number,
                        height: 40,
                        controller: priceController,
                        onPress: () {},
                        validator: (String input) {
                          if (input.isEmpty) {
                            Get.snackbar('Opps', "Price is required.",
                                colorText: Colors.white,
                                backgroundColor: Colors.blue);
                            return '';
                          }
                        })
                  ],
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                Obx(() => isCreatingEvent.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        height: 42,
                        width: double.infinity,
                        child: elevatedButton(
                            onpress: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              /*if (media.isEmpty) {
                                Get.snackbar('Opps', "Media is required.",
                                    colorText: Colors.white,
                                    backgroundColor: Colors.blue);

                                return;
                              }*/

                              if (tagsController.text.isEmpty) {
                                Get.snackbar('Opps', "Tags is required.",
                                    colorText: Colors.white,
                                    backgroundColor: Colors.blue);

                                return;
                              }

                              isCreatingEvent(true);

                              DataController dataController = Get.find();

                              if (media.isNotEmpty) {
                                for (int i = 0; i < media.length; i++) {
                                  if (media[i].isVideo!) {
                                    /// if video then first upload video file and then upload thumbnail and
                                    /// store it in the map

                                    String thumbnailUrl = await dataController
                                        .uploadThumbnailToFirebase(
                                            media[i].thumbnail!);

                                    String videoUrl = await dataController
                                        .uploadImageToFirebase(media[i].video!);

                                    mediaUrls.add({
                                      'url': videoUrl,
                                      'thumbnail': thumbnailUrl,
                                      'isImage': false
                                    });
                                  } else {
                                    /// just upload image

                                    String imageUrl = await dataController
                                        .uploadImageToFirebase(media[i].image!);
                                    mediaUrls.add(
                                        {'url': imageUrl, 'isImage': true});
                                  }
                                }
                              }

                              List<String> tags =
                                  tagsController.text.split(',');

                              Map<String, dynamic> eventData = {
                                'event': event_type,
                                'event_name': titleController.text,
                                'location': locationController.text,
                                'date':
                                    '${date!.day}-${date!.month}-${date!.year}',
                                'start_time': startTimeController.text,
                                'end_time': endTimeController.text,
                                'max_entries': int.parse(maxEntries.text),
                                'frequency_of_event':
                                    frequencyEventController.text,
                                'description': descriptionController.text,
                                'who_can_invite': accessModifier,
                                'joined': [
                                  FirebaseAuth.instance.currentUser!.uid
                                ],
                                'price': priceController.text,
                                'media': mediaUrls,
                                'uid': FirebaseAuth.instance.currentUser!.uid,
                                'tags': tags,
                                'inviter': [
                                  FirebaseAuth.instance.currentUser!.uid
                                ]
                              };

                              await dataController
                                  .createEvent(eventData)
                                  .then((value) {
                                print("Event is done");
                                isCreatingEvent(false);
                                resetControllers();
                              });
                            },
                            text: 'Create Event'),
                      )),
                SizedBox(
                  height: Get.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getImageDialog(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(
      source: source,
    );

    if (image != null) {
      media.add(EventMediaModel(
          image: File(image.path), video: null, isVideo: false));
    }

    setState(() {});
    Navigator.pop(context);
  }

  getVideoDialog(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? video = await picker.pickVideo(
      source: source,
    );

    if (video != null) {
      // media.add(File(image.path));

      Uint8List? uint8list = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      media.add(EventMediaModel(
          thumbnail: uint8list!, video: File(video.path), isVideo: true));
      // thumbnail.add(uint8list!);
      //
      // isImage.add(false);
    }

    // print(thumbnail.first.path);
    setState(() {});

    Navigator.pop(context);
  }

  void mediaDialog(BuildContext context) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Media Type"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      imageDialog(context, true);
                    },
                    icon: const Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      imageDialog(context, false);
                    },
                    icon: const Icon(Icons.slow_motion_video_outlined)),
              ],
            ),
          );
        },
        context: context);
  }

  void imageDialog(BuildContext context, bool image) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Media Source"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      if (image) {
                        getImageDialog(ImageSource.gallery);
                      } else {
                        getVideoDialog(ImageSource.gallery);
                      }
                    },
                    icon: const Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      if (image) {
                        getImageDialog(ImageSource.camera);
                      } else {
                        getVideoDialog(ImageSource.camera);
                      }
                    },
                    icon: const Icon(Icons.camera_alt)),
              ],
            ),
          );
        },
        context: context);
  }
}
