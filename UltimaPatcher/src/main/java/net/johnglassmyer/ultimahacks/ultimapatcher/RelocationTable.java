package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.SortedSet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.collect.ImmutableSet;

abstract class RelocationTable {
	static private Logger L = LogManager.getLogger(RelocationTable.class);

	final int startInFile;
	final ImmutableSet<Integer> originalAddresses;

	protected RelocationTable(int startInFile, ImmutableSet<Integer> originalAddresses) {
		this.startInFile = startInFile;
		this.originalAddresses = originalAddresses;
	}

	Collection<OverwriteEdit> produceEdits(SortedSet<Integer> replacementAddresses) {
		// TODO: check replacementAddresses.size() against table "capacity" in some meaningful way

		if (replacementAddresses.equals(originalAddresses)) {
			return Collections.emptySet();
		}

		List<OverwriteEdit> edits = new ArrayList<>();
		if (replacementAddresses.size() != originalAddresses.size()) {
			edits.add(produceCountEdit(replacementAddresses.size()));
		}

		edits.add(produceTableEdit(Collections.unmodifiableSortedSet(replacementAddresses)));

		return edits;
	}

	protected abstract OverwriteEdit produceCountEdit(int newCount);

	protected abstract OverwriteEdit produceTableEdit(SortedSet<Integer> relocationSitesInFile);
}