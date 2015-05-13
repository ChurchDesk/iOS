# Copy artifacts to ipa folder
CONFIGURATION=$1
for ipa in pkg/dist/*.ipa; do
	ipa=$(basename $ipa)
	cp "pkg/dist/$ipa" "ipa/$CONFIGURATION$ipa"
done
for dsym in build/Products/$CONFIGURATION-iphoneos/*.dSYM; do
	dsym=$(basename $dsym)
	zip -r "ipa/$CONFIGURATION$dsym.zip" "build/Products/$CONFIGURATION-iphoneos/$dsym"
done
