import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/test_provider.dart';
import 'package:logger/logger.dart';
import 'package:careeasy/provider/user_info_provider.dart';

class ProviderTest extends StatefulWidget {
  const ProviderTest({super.key});

  // late ProviderTest _ProviderTest;
  @override
  State<ProviderTest> createState() => ProviderTestState();
}

class ProviderTestState extends State<ProviderTest> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final logger = Logger(printer: PrettyPrinter());
  
  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void defaultSetting () {
    nameController.text = context.watch<UserInfoProvider>().name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    CountProvider countProvider = Provider.of<CountProvider>(context,listen: false);
    UserInfoProvider userInfoProvider = Provider.of<UserInfoProvider>(context,listen: false);
    defaultSetting();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ProviderTest"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                // onPressed: () => context.read<CountProvider>().increase(),
                onPressed: () => countProvider.increase(),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                //onPressed: () => context.read<CountProvider>().decrease(),
                onPressed: () => countProvider.decrease(),
                icon: const Icon(Icons.remove)
              ),
              Text('${context.watch<CountProvider>().count}')
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0,),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'age',
                  ),
                ),
                const SizedBox(height: 10.0,),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'email',
                  ),
                ),
                const SizedBox(height: 60.0,),
                ElevatedButton(
                  onPressed: (){
                    // FocusManager.instance.primaryFocus?.unfocus();
                    FocusScope.of(context).requestFocus(FocusNode());
                    userInfoProvider.userInfo(nameController.text, ageController.text, emailController.text, true);
                    Navigator.pop(context);
                  },
                  child: const Text("SUBMIT")
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}