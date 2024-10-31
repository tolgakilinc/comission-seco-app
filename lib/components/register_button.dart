import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Buton tam genişlikte olacak
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.redAccent,
              ),
        child: const Text(
          'Kaydet',
          style: TextStyle(fontSize: 18) ,
        ),
      ),
    );
  }
}
