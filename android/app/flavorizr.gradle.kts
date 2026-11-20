import com.android.build.api.dsl.ApplicationExtension

val android = project.extensions.getByType(ApplicationExtension::class.java)

android.apply {
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "flavor-type"

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.geolocator_app.dev"
            resValue("string", "app_name", "GPS Tracking Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.example.geolocator_app.staging"
            resValue("string", "app_name", "GPS Tracking Staging")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.example.geolocator_app"
            resValue("string", "app_name", "GPS Tracking")
        }
    }
}
