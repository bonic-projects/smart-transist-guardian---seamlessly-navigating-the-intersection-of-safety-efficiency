import 'package:flutter/material.dart';
import 'package:smart_transist_guardian/ui/views/controlroom/controlroom_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ControlRoomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ControlRoomViewModel>.reactive(
      viewModelBuilder: () => ControlRoomViewModel(),
      onModelReady: (viewModel) => viewModel.runStartupLogic(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Control Room",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () {
                  viewModel.logout();
                },
              )
            ],
          ),
          body: viewModel.isAccident
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      // Map for Accident Location
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  viewModel.deviceData?.accident.latitude ??
                                      0.0,
                                  viewModel.deviceData?.accident.longitude ??
                                      0.0),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId("accident_location"),
                                position: LatLng(
                                    viewModel.deviceData?.accident.latitude ??
                                        0.0,
                                    viewModel.deviceData?.accident.longitude ??
                                        0.0),
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

                      // Accident Data Card
                      _buildDataCard(
                        title: 'Accident Details',
                        icon: Icons.local_offer,
                        children: [
                          _buildDataRow(
                              'Latitude:',
                              viewModel.deviceData?.accident.latitude
                                      .toString() ??
                                  'N/A'),
                          _buildDataRow(
                              'Longitude:',
                              viewModel.deviceData?.accident.longitude
                                      .toString() ??
                                  'N/A'),
                        ],
                      ),

                      // Gate Status Card
                      _buildDataCard(
                        title: 'Gate Status',
                        icon: Icons.door_front_door,
                        children: [
                          _buildDataRow('Gate 1 Status:',
                              viewModel.deviceData?.gate1.status ?? 'N/A'),
                          _buildDataRow('Gate 2 Status:',
                              viewModel.deviceData?.gate2.status ?? 'N/A'),
                          _buildDataRow('Gate 2 Traffic:',
                              viewModel.deviceData?.gate2.traffic ?? 'Unknown'),
                        ],
                      ),

                      // Traffic Data Card
                      _buildDataCard(
                        title: 'Traffic Information',
                        icon: Icons.traffic,
                        children: [
                          _buildDataRow('Traffic Status:',
                              viewModel.deviceData?.traffic ?? 'Unknown'),
                        ],
                      ),

                      // Route Details
                      _buildRouteCard(viewModel),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    "No accident detected",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                ),
        );
      },
    );
  }

  // Helper method to build data cards with titles and content
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a row of data inside the card
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Helper method to show route to accident
  Widget _buildRouteCard(ControlRoomViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<LatLng>>(
            future: viewModel.getRouteToAccident(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error fetching route');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No route available');
              }

              // Display Route Points
              List<LatLng> route = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route to Accident Location:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  ...route.map((point) {
                    return Text(
                      'Lat: ${point.latitude}, Lon: ${point.longitude}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
