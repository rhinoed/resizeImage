
resizeImage:
	@echo "building resizeImage...\n"
	@swift build -v --configuration release
	@echo "build complete copying files..."
	@install .build/release/resizeImage /usr/local/bin
	@echo "sourcing binary..."
 
