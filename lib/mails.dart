// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';

// Future<void> sendEmail(String recipientEmail) async {
//   // Define your SMTP server settings
//   String username = '';
//   String password = '';

//   final smtpServer = SmtpServer('mail.opengoalz.ovh',
//       username: username, password: password, port: 587);

//   // Create the email message
//   final message = Message()
//     ..from = Address(username, 'Your App Name')
//     ..recipients.add(recipientEmail)
//     ..subject = 'Email Confirmation'
//     ..text =
//         'Please confirm your email address using the following link: [your confirmation link]';

//   try {
//     final sendReport = await send(message, smtpServer);
//     print('Email sent: ' + sendReport.toString());
//   } on MailerException catch (e) {
//     print('Email failed to send: $e');
//   }
// }
