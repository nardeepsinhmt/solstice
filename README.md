Solstice - Flutter Application
Welcome to the Solstice Flutter project! This Flutter application is designed to manage and display a list of terms and conditions, 
as well as provide features for adding or editing new terms and conditions. The project utilizes various packages and technologies for different functionalities.

State Management
We have implemented state management in this project using Bloc and Cubit.
Bloc is used to handle the state of the application, making it efficient and organized.

Terms and Conditions
We store the terms and conditions in JSON format within the assets of the application. 
To retrieve and manage these terms, we utilize the Bloc pattern with events. This allows us to efficiently handle the display and manipulation of the 
terms and conditions.

Screens

Terms Screen
The 'Terms Screen' is the main screen of the application. It displays a list of the stored terms and conditions to the user.
Users can view and interact with these terms.

Add Term Bottom Sheet
The 'Add Term Bottom Sheet' is a user-friendly interface for adding or editing new terms and conditions. 
It provides a convenient way to input and modify terms and conditions. Speech-to-text functionality is also integrated into this screen, making it easier for users 
to add terms through voice input.

Language Translation
For translating terms from English to Hindi, we have employed the Google ML Kit Translation package. 
This feature allows users to seamlessly switch between languages and access terms in both English and Hindi.

Speech to Text
To facilitate speech-to-text functionality within the 'Add Term Bottom Sheet,' 
we have integrated the speech_to_text package, version 6.3.0. This feature enables users to add terms and conditions through voice input.

Permission Handling
To manage app permissions, such as microphone access for speech-to-text functionality, 
we have used the permission_handler package, version 11.0.0. This ensures that the app requests and handles necessary permissions appropriately.


                                 ####################### How to use App ######################

Here's a step-by-step guide on how to use the application based on the details you provided:

Step 1: Open the Application
Locate the application icon on your device and tap on it to open the app.

Step 2: Home Screen
Upon opening the application, you will land on the home screen.

Step 3: List of Terms and Conditions
On the home screen, you will see a list of terms and conditions. Each item in the list is associated with a "Read in Hindi" button.

Step 4: Download Hindi Model
The first time you click on the "Read in Hindi" button of any list item, the app will download the Hindi model. This is a one-time setup.

Step 5: Translate Text to Hindi
After downloading the Hindi model, you can translate the text of any list item into Hindi by clicking on the "Read in Hindi" button for that item.

Step 6: Edit Terms and Conditions
To edit the terms and conditions of any item, click on the item itself. This action will open a bottom sheet.

Step 7: Bottom Sheet with Edit Options
Inside the bottom sheet, you will find an edit text field where you can modify the terms and conditions.
There should also be a microphone option, allowing you to use voice input for editing.

Step 8: Update Existing Terms and Conditions
After making your edits, click on the "Update" button (or a similar button) within the bottom sheet to save the changes you made to the existing terms and conditions.

Step 9: Add New Terms and Conditions
Scroll to the end of the list of terms and conditions.

Step 10: Option to Add More
At the end of the list, you will find an option to "Add More." Click on this option.

Step 11: Bottom Sheet to Add New Terms
Clicking on "Add More" will open a bottom sheet that allows you to add new terms and conditions to the list.
Similar to the editing process, this bottom sheet should also have an edit text field and a microphone option for adding new terms.

Step 12: Translate Written Text to Hindi
Within the bottom sheet for adding new terms, there should be an option to "Read in Hindi," which can be used to translate the written text into Hindi
before adding it to the list. That's it! You have now learned how to use the application to read, edit, and add terms and conditions in Hindi.
Remember that downloading the Hindi model is a one-time step, and after that, you can easily translate and work with the text in Hindi as needed.
