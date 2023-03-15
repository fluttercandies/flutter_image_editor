export WORK_DIR=$PWD

echo "Set the work to ${WORK_DIR}"

# Get the binary library
dart pub global activate dartdoc

check_code(){
    cd "$WORK_DIR/$1"

    # Check code
    echo "Run flutter pub get in $PWD"
    flutter pub get

    # Analyse code
    echo "Analyse code in $PWD"
    flutter analyze lib

    # Generate docs
    echo "Generate docs in $PWD"
    dart pub global run dartdoc

    # Analyze if the "example" folder exists.
    if [ -d "example" ]; then
        echo "Analyse example code in $PWD"
        cd example
        flutter pub get
        flutter analyze lib
    fi

    # Run tests if the "test" folder exists.
    if [ -d "test" ]; then
        echo "Running tests in $PWD"
        flutter test
    fi
}


check_code "image_editor"
check_code "image_editor_common"
check_code "image_editor_platform_interface"
