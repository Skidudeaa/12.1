//
//  start.swift
//  12.01
//
//  Created by Thomas Amosson on 2023.12.02.
//



/*
struct WelcomeView: View {
    @State private var selectedFile = "Well"
    @State private var selectedImage = "juiceArt"
    let fileNames = ["fallingDown",  "drew", "moon", "pyscho2", "fallApart", "twenty", "wantLove", "congrats", "animal", "aMess", "mama", "glass", "switch", "flora", "cameras3", "letMeFall",  "righteous1",   "everlong", "heartless", "notAfraid", "circles", "otherside", "soundtrack", "Well"]  // replace with your actual file names
    let imageNames = ["fallingDownArt",  "pyscho2.Art", "aMessArt", "mamaArt", "glassArt", "floraArt", "wizArt", "BOBart", "juiceArt",  "notAfraidArt", "circlesArt", "postArt", "soundtrack", "drownArt", "moonArt", "drewArt", "wantLoveArt", "congratsArt", "congratsArt", "switchArt", "funeralArt",  "animalArt",  "twentyArt"] // replace with your actual image names

    var body: some View {
        NavigationView {
            Form {
                Picker("Select JSON File", selection: $selectedFile) {
                    ForEach(fileNames, id: \.self) { fileName in
                        Text(fileName)
                    }
                }
                Picker("Select Image", selection: $selectedImage) {
                    ForEach(imageNames, id: \.self) { imageName in
                        Text(imageName)
                    }
                }
                NavigationLink("Load", destination: SongView(fileName: selectedFile, imageName: selectedImage))
            }
            .navigationBarTitle("Welcome")
        }
    }
}
*/
