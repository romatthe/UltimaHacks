package net.johnglassmyer.ultimahacks.ultimapatcher;

class LoadModule {
	final MzHeader mzHeader;
	final LoadModuleRelocationTable relocationTable;

	LoadModule(MzHeader mzHeader, LoadModuleRelocationTable relocationTable) {
		this.mzHeader = mzHeader;
		this.relocationTable = relocationTable;
	}
}
