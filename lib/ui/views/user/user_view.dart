import 'package:flutter/material.dart';
import 'package:smart_transist_guardian/ui/views/user/user_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserViewModel>.reactive(
      viewModelBuilder: () => UserViewModel(),
      onModelReady: (viewModel) => viewModel.runStartupLogic(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "User View",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue[900], // Consistent primary color
            elevation: 0,
            actions: [
              IconButton(
                onPressed: viewModel.logout,
                icon: Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          body: Column(
            children: [
              // Input Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Current Location TextField with Icon to fetch location
                    TextField(
                      controller: TextEditingController(
                        text: viewModel.currentLocation != null
                            ? 'Lat: ${viewModel.currentLocation?.latitude}, Lng: ${viewModel.currentLocation?.longitude}'
                            : 'Fetching location...',
                      ),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Current Location',
                        prefixIcon: GestureDetector(
                          onTap: () {
                            viewModel.fetchCurrentLocation();
                          },
                          child: Icon(Icons.location_searching, color: Colors.blue[900]),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue[900]!),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Destination Location TextField with TypeAheadField
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[900]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TypeAheadField<String>(
                          controller: viewModel.destinationController,
                          suggestionsCallback: (pattern) async {
                            return await viewModel.fetchPlaceSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (suggestion) {
                            viewModel.selectPlace(suggestion);
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Destination',
                                border: InputBorder.none, // Remove the default border
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.location_on, color: Colors.blue[900]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Fetch Route Button
                    ElevatedButton(
                      onPressed: () async {
                        if (viewModel.destinationLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a destination first!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        var route = await viewModel.getRouteToDestination();
                        viewModel.clearRoute();
                        viewModel.updatePolylines(route);

                        if (viewModel.isAccidentOnRoute(route)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Warning: Accident detected on your route!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Fetch Route',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900], // Consistent primary color
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Accident Data Section
              viewModel.isAccident
                  ? Expanded(
                child: SingleChildScrollView(
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
                                viewModel.deviceData?.accident.latitude ?? 0.0,
                                viewModel.deviceData?.accident.longitude ?? 0.0,
                              ),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId("accident_location"),
                                position: LatLng(
                                  viewModel.deviceData?.accident.latitude ?? 0.0,
                                  viewModel.deviceData?.accident.longitude ?? 0.0,
                                ),
                                infoWindow: InfoWindow(
                                  title: 'Accident Location',
                                  snippet: 'Accident occurred here',
                                ),
                              ),
                            },
                            polylines: viewModel.polylines,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
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
                            viewModel.deviceData?.accident.latitude.toString() ?? 'N/A',
                          ),
                          _buildDataRow(
                            'Longitude:',
                            viewModel.deviceData?.accident.longitude.toString() ?? 'N/A',
                          ),
                        ],
                      ),

                      // Gate Status Card
                      _buildDataCard(
                        title: 'Gate Status',
                        icon: Icons.door_front_door,
                        children: [
                          _buildDataRow(
                            'Gate 1 Status:',
                            viewModel.deviceData?.gate1.status ?? 'N/A',
                          ),
                          _buildDataRow(
                            'Gate 2 Status:',
                            viewModel.deviceData?.gate2.status ?? 'N/A',
                          ),
                          _buildDataRow(
                            'Gate 2 Traffic:',
                            viewModel.deviceData?.gate2.traffic ?? 'Unknown',
                          ),
                          _buildDataRow(
                            'Gate 2 Remaining Time:',
                            viewModel.deviceData?.gate2.remainingTime.toString() ?? 'N/A',
                          ),
                        ],
                      ),

                      // Traffic Status Card
                      _buildDataCard(
                        title: 'Traffic Information',
                        icon: Icons.traffic,
                        children: [
                          _buildDataRow(
                            'Traffic Status:',
                            viewModel.deviceData?.traffic ?? 'Unknown',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : Center(
                child: Text(
                  "No accident detected",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
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

  // Helper method to build a row of data inside the card
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