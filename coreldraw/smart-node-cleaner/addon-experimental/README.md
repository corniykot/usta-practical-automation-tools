# USTA Smart Node Cleaner — experimental UI add-on

**Prototype only. Not included in the installer.**

This follows CorelDRAW's documented `AppUI.xslt` / `UserUI.xslt` add-on mechanism. It declares the existing VBA command `UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV073` and attempts to add a button to the standard CorelDRAW toolbox.

The toolbar GUID comes from CorelDRAW developer documentation. The macro command string was checked against an existing CorelDRAW 2018 `.cdws` file.

**Known limitations**
- The icon currently uses CorelDRAW's built-in image slot; custom USTA `.ico` integration has **not** been solved or verified.
- `UserUI.xslt` may only be applied when CorelDRAW first initializes a workspace. Existing customized workspaces may show no change. **Do not press F8 to reset your main workspace.**
- The supported add-on directory is normally `<CorelDRAW installation>\\Programs64\\Addons\\<AddOnName>` for 64-bit CorelDRAW. Writing there typically requires administrator rights.
- We have not tested this prototype in CorelDRAW 2018. It must not be deployed to users or added to the release installer yet.

**Testing without risking the real workspace**

Use a disposable CorelDRAW workspace or separate Windows test account. Install the `Coreldrw.addon`, `AppUI.xslt`, and `UserUI.xslt` files in a dedicated `USTASmartNodeCleaner` subdirectory under the CorelDRAW Addons folder. Restart CorelDRAW. Confirm the new command appears and opens the correct v0.73 form; confirm removal of the add-on does not alter existing workspaces.

The add-on is intentionally independent of the binary `.gms` macro, which is delivered by the existing installer.

CorelDRAW documentation: https://community.coreldraw.com/sdk/w/articles/173/custom-add-ons-in-coreldraw-corel-designer-and-corel-photo-paint
