import 'dart:io'; // Import this for File
import 'package:account/main.dart';
import 'package:account/models/transactions.dart';
import 'package:account/provider/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditScreen extends StatefulWidget {
  final Transactions statement;

  const EditScreen({super.key, required this.statement});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final contactController = TextEditingController(); 
  final descriptionController = TextEditingController(); 
  final fieldController = TextEditingController(); 
  DateTime? selectedDate;
  TimeOfDay? selectedTime; // เพิ่มตัวแปรสำหรับเวลา
  String? imagePath; // Variable to hold the selected image path
  final ImagePicker _picker = ImagePicker(); // Create an instance of ImagePicker

  @override
  void initState() {
    super.initState();
    titleController.text = widget.statement.title;
    amountController.text = widget.statement.amount.toString();
    contactController.text = widget.statement.contact;
    descriptionController.text = widget.statement.description;
    fieldController.text = widget.statement.field;
    selectedDate = widget.statement.date;
    imagePath = widget.statement.image; // Initialize with the current image
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; 
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked; // Update selected time
      });
    }
  }

  Future<void> _selectImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Pick image from gallery
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path; // Update the image path
      });
    }
  }

  void _clearFields() {
    titleController.clear();
    amountController.clear();
    contactController.clear();
    descriptionController.clear();
    fieldController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null; // Clear selected time
      imagePath = null; // Clear image path
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แบบฟอร์มแก้ไขข้อมูล'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display the selected date
              ListTile(
                title: Text(
                  selectedDate == null
                      ? 'เลือกวันที่'
                      : 'วันที่: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              // Display the selected time
              ListTile(
                title: Text(
                  selectedTime == null
                      ? 'เลือกเวลา'
                      : 'เวลา: ${selectedTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context), // Allow user to select time
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ชื่อหมอดู',
                ),
                controller: titleController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'โปรราคาเท่าไหร่',
                ),
                keyboardType: TextInputType.number,
                controller: amountController,
                validator: (String? input) {
                  if (input == null || input.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                  try {
                    double amount = double.parse(input);
                    if (amount <= 0) {
                      return 'กรุณากรอกข้อมูลมากกว่า 0';
                    }
                  } catch (e) {
                    return 'กรุณากรอกข้อมูลเป็นตัวเลข';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ช่องทางการนัดหมาย',
                ),
                controller: contactController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลการติดต่อ';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด',
                ),
                controller: descriptionController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลรายละเอียด';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ศาสตร์ที่ใช้',
                ),
                controller: fieldController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลศาสตร์ที่ใช้';
                  }
                  return null;
                },
              ),
              // Display the current or selected image
              GestureDetector(
                onTap: _selectImage, // Allow tapping to select a new image
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    image: imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(imagePath!)), // Display selected image
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imagePath == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : null, // Show icon if no image is selected
                ),
              ),
              TextButton(
                child: const Text('แก้ไขข้อมูล'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Create DateTime object with selected date and time
                    DateTime combinedDateTime = DateTime(
                      selectedDate?.year ?? DateTime.now().year,
                      selectedDate?.month ?? DateTime.now().month,
                      selectedDate?.day ?? DateTime.now().day,
                      selectedTime?.hour ?? DateTime.now().hour,
                      selectedTime?.minute ?? DateTime.now().minute,
                    );

                    // Create transaction data object
                    var statement = Transactions(
                      keyID: widget.statement.keyID,
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      date: combinedDateTime, // Use combined date and time
                      contact: contactController.text,
                      description: descriptionController.text,
                      field: fieldController.text,
                      image: imagePath, // Include the updated image path
                    );

                    // Update transaction in provider
                    var provider = Provider.of<TransactionProvider>(context, listen: false);
                    provider.updateTransaction(statement);

                    // Clear fields after submission
                    _clearFields();

                    // Navigate to the home page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const MyHomePage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
