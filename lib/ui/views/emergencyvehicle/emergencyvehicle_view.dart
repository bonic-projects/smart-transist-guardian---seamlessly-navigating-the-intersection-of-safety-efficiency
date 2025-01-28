import 'package:flutter/material.dart';
import 'package:smart_transist_guardian/ui/views/emergencyvehicle/emergencyvehicle_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyVehicleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EmergencyVehicleViewModel>.reactive(
      viewModelBuilder: () => EmergencyVehicleViewModel(),
      onModelReady: (viewModel) => viewModel.runStartupLogic(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900], // Consistent primary color
            title: Text(
              'Emergency Vehicle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  viewModel.logout();
                },
                icon: Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          body: viewModel.isBusy
              ? Center(child: CircularProgressIndicator())
              : viewModel.assignedAccident == null
              ? Center(
            child: Text(
              'No accident assigned',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
          )
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataCard(
                  title: "Accident Details",
                  icon: Icons.location_on_rounded,
                  children: [
                    _buildDataRow(
                      'Latitude:',
                      viewModel.assignedAccident?.latitude.toString() ?? 'N/A',
                    ),
                    _buildDataRow(
                      'Longitude:',
                      viewModel.assignedAccident?.longitude.toString() ?? 'N/A',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          viewModel.assignedAccident?.latitude ?? 0.0,
                          viewModel.assignedAccident?.longitude ?? 0.0,
                        ),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId("accident_location"),
                          position: LatLng(
                            viewModel.assignedAccident?.latitude ?? 0.0,
                            viewModel.assignedAccident?.longitude ?? 0.0,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Accident Location',
                            snippet: 'Accident occurred here',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId != null) {
                          await viewModel.markAccidentAsDone(userId);
                        } else {
                          print('User is not logged in');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900], // Consistent primary color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Mark as Done',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue[900]), // Consistent primary color
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900], // Consistent primary color
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300]),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}