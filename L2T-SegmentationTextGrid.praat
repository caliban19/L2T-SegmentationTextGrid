

procedure segmentation_textgrid_tiers: .activity$
  # String constants for the tiers of a Segmentation TextGrid (1-5) and the
  # tiers of a Checked Segmentation TextGrid (1-9)
  .trial             = 1
  .trial$            = "Trial"
  .word              = 2
  .word$             = "Word"
  .context           = 3
  .context$          = "Context"
  .repetition        = 4
  .repetition$       = "Repetition"
  .segm_notes        = 5
  .segm_notes$       = "SegmNotes"
  .check_trial       = 6
  .check_trial$      = "CheckedTrial"
  .check_word        = 7
  .check_word$       = "CheckedWord"
  .check_context     = 8
  .check_context$    = "CheckedContext"
  .check_repetition  = 9
  .check_repetition$ = "CheckedRepetition"
  .check_notes       = 10
  .check_notes$      = "CheckedNotes"
  .to_review         = 11
  .to_review$        = "ToReview"
  # Gather the string constants into a vector---which string constants are 
  # gathered depends on the [.activity$].
  @praat_activities
  if .activity$ == praat_activities.segment$
    .slot1$ = .trial$
    .slot2$ = .word$
    .slot3$ = .context$
    .slot4$ = .repetition$
    .slot5$ = .segm_notes$
    .length = 5
    # A few other string constants that facilitate creating a new
    # Segmentation TextGrid.
    .all_tiers$ = .slot1$
    for i from 2 to .length
      .all_tiers$ = .all_tiers$ + " " + .slot'i'$
    endfor
    .point_tiers$ = .segm_notes$
  elif .activity$ == praat_activities.check$
    .slot1$  = .trial$
    .slot2$  = .word$
    .slot3$  = .context$
    .slot4$  = .repetition$
    .slot5$  = .segm_notes$
    .slot6$  = .check_trial$
    .slot7$  = .check_word$
    .slot8$  = .check_context$
    .slot9$  = .check_repetition$
    .slot10$ = .check_notes$
    .slot11$ = .to_review$
    .length  = 11
    # A few other string constants that facilitate creating a new
    # Segmentation TextGrid.
    .all_tiers$ = .slot1$
    for i from 2 to .length
      .all_tiers$ = .all_tiers$ + " " + .slot'i'$
    endfor
    .point_tiers$ = .segm_notes$ + " " + .check_notes$ + " " + .to_review$
  endif
endproc




procedure segmentation_textgrid_error: .directory$ 
                                   ... .participant_number$
  printline
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline ERROR :: No Segmentation TextGrid was loaded
  printline
  printline Make sure the following directory exists on your computer:
  printline '.directory$'
  printline 
  printline Also, make sure that directory contains a Segmentation TextGrid
        ... for participant '.participant_number$'.
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline 
endproc


procedure initialize_segmentation_textgrid
  @participant: segmentation_log.write_to$, 
            ... session_parameters.participant_number$
  select 'audio.praat_obj$'
  To TextGrid... "'segmentation_textgrid_tiers.all_tiers$'"
             ... 'segmentation_textgrid_tiers.point_tiers$'
  Rename... 'participant.id$'_Segm'session_parameters.initials$'
  .praat_obj$ = selected$()
endproc


procedure segmentation_log_is
  .activity$ = session_parameters.activity$
  @praat_activities
  if .activity$ == praat_activities.segment$
    .ready = 1
  elif .activity$ == praat_activities.check$
    # Check whether the Segmentation Log exists on the Praat Objects list.
    .on_objects_list = segmentation_log.praat_obj$ <> ""
    # Check whether the Segmentation Log has unchecked trials.
    select 'segmentation_log.praat_obj$'
    .n_trials  = Get value... 'segmentation_log.row_on_segmentation_log'
                          ... 'segmentation_log_columns.trials$'
    .n_checked = Get value... 'segmentation_log.row_on_segmentation_log'
                          ... 'segmentation_log_columns.segmented_trials$'
    .has_unchecked_trials = .n_checked < .n_trials
    # Determine whether the Segmentation Log is [.ready] for the Segmentation
    # TextGrid to be loaded.
    .ready = .on_objects_list * .has_unchecked_trials
  endif
endproc




procedure prepare_segmented_textgrid: .praat_obj$
  select '.praat_obj$'
  .n_tiers = Get number of tiers
  .ready_to_check = 0
  if .n_tiers < 11
    if .n_tiers == 5
      @segmentation_textgrid_tiers: session_parameters.activity$
      select '.praat_obj$'
## PFR: Added calls to [Insert interval tier] so that CheckedTrial and
##      CheckedWord tiers would be added to the original segmentation tiers
##      when it is first being checked.
      Insert interval tier: segmentation_textgrid_tiers.check_trial, 
                        ... segmentation_textgrid_tiers.check_trial$
      Insert interval tier: segmentation_textgrid_tiers.check_word,
                        ... segmentation_textgrid_tiers.check_word$
## /PFR 2014-08-01
      Insert interval tier: segmentation_textgrid_tiers.check_context, 
                        ... segmentation_textgrid_tiers.check_context$
      Insert interval tier: segmentation_textgrid_tiers.check_repetition,
                        ... segmentation_textgrid_tiers.check_repetition$
      Insert point tier: segmentation_textgrid_tiers.check_notes, 
                     ... segmentation_textgrid_tiers.check_notes$
      Insert point tier: segmentation_textgrid_tiers.to_review, 
                     ... segmentation_textgrid_tiers.to_review$
      .ready_to_check = 1
    else
      printline The Segmented TextGrid has a wrong number of tiers.
      printline It should have either 5 or 11 tiers, but it has '.n_tiers'.
      printline Please fix the structure of the Segmented TextGrid and then
            ... rerun this script.
    endif  
  elif .n_tiers == 11
    # Then everything is good, so don't do anything.
    .ready_to_check = 1
  elif .n_tiers > 11
    printline The Segmented TextGrid has a wrong number of tiers.
    printline It should have either 5 or 11 tiers, but it has '.n_tiers'.
    printline Please fix the structure of the Segmented TextGrid and then
          ... rerun this script.
  endif
endproc




procedure segmentation_textgrid
  # Import constants from the [session_parameters] namespace.
  .initials$             = session_parameters.initials$
  .workstation$          = session_parameters.workstation$
  .experimental_task$    = session_parameters.experimental_task$
  .testwave$             = session_parameters.testwave$
  .participant_number$   = session_parameters.participant_number$
  .activity$             = session_parameters.activity$
  .experiment_directory$ = session_parameters.experiment_directory$
  # Set up the [segmentation_textgrid_tiers] namespace.
  @segmentation_textgrid_tiers: .activity$
  # The behavior of the procedure depends primarily on the [.activity$].
  @praat_activities
  if .activity$ == praat_activities.segment$
    # Set up the path to the segmenter's working [.directory$].
    .directory$ = .experiment_directory$ + "/" +
              ... "Segmentation" + "/" + 
              ... "Segmenters" + "/" + 
              ... .initials$ + "/" +
              ... "TextGrids"
    # Parse the full [participant.id$] from the path of the Segmentation Log
    @participant: segmentation_log.write_to$,
              ... session_parameters.participant_number$
    # If the Segmentation Log was created at run time---i.e., not [.read_from$]
    # the filesystem, then the TextGrid needs to be created at run time as well.
    if segmentation_log.read_from$ == ""
      prinline Creating a blank Segmentation TextGrid
      # Create a blank Segmentation TextGrid.
      @initialize_segmentation_textgrid
      # Set up the [.read_from$], [.write_to$] and [.praat_obj$] strings.
      .read_from$ = ""
      .write_to$ = .directory$ + "/" +
               ... .experimental_task$ + "_" +
               ... participant.id$ + "_" +
               ... .initials$ + "segm.Textgrid"
      .praat_obj$ = initialize_segmentation_textgrid.praat_obj$
    else
      .pattern$ = .directory$ + "/" + 
              ... .experimental_task$ + "_" +
              ... .participant_number$ + "*" +
              ... .initials$ + "segm.TextGrid"
      # Use the [.pattern$] to determine the filename of the Segmentation
      # TextGrid.
      @filename_from_pattern: .pattern$, "Segmentation TextGrid"
      if filename_from_pattern.filename$ <> ""
        .read_from$ = .directory$ + "/" + filename_from_pattern.filename$
        .write_to$  = .directory$ + "/" + filename_from_pattern.filename$
        printline Loading Segmentation TextGrid
              ... 'filename_from_pattern.filename$' from '.directory$'
        Read from file... '.read_from$'
        Rename... 'participant.id$'_Segm'.initials$'
        .praat_obj$ = selected$()
      else
        .read_from$ = ""
        .write_to$  = ""
        .praat_obj$ = ""
      endif
    endif


  # When checking a Segmented TextGrid...
  elif .activity$ == praat_activities.check$
    # Only load a Segmentation TextGrid if the [segmentation_log_is] [.ready]
    @segmentation_log_is
    if segmentation_log_is.ready
      # Get the intials of the segmenter who segmented the TextGrid.
      @segmenters_initials: segmentation_log.read_from$
      .segmenters_initials$ = segmenters_initials.initials$
      # Get the [checking_initials] as well.
      @checking_initials: segmentation_log.read_from$, .initials$
      .checking_initials$ = checking_initials.initials$
      # Use the segmenter's initials, among other pieces of information, to
      # set up the path to that segmenter's working [.directory$]
      .directory$ = .experiment_directory$ + "/" +
                ... "Segmentation" + "/" +
                ... "Segmenters" + "/" +
                ... .segmenters_initials$ + "/" +
                ... "TextGrids"
      # The [.pattern$] used to search for a Segmented TextGrid depends on
      # whether the user is continuing a previous session or if this is her
      # first session checking these segmentations.
      if ! segmentation_log.continuing_previous_session
        .pattern$   = .directory$ + "/" +
                  ... .experimental_task$ + "_" +
                  ... .participant_number$ + "*" +
                  ... .segmenters_initials$ + "segm.TextGrid"
      else
        .pattern$   = .directory$ + "/" +
                  ... .experimental_task$ + "_" +
                  ... .participant_number$ + "*" +
                  ... .checking_initials$ + "segm.TextGrid"
      endif
      # Use the [.pattern$] to determine the filename of the Segmentation
      # TextGrid.
      @filename_from_pattern: .pattern$, "Segmented TextGrid"
      if filename_from_pattern.filename$ <> ""
        # Use the [.filename$] to set up the [.read_from$] and [.write_to$]
        # paths.
        .read_from$ = .directory$ + "/" + filename_from_pattern.filename$
        if ! segmentation_log.continuing_previous_session
          .write_to$  = replace$(.read_from$, "'.segmenters_initials$'segm",
                              ... "'.checking_initials$'segm", 1)
        else
          .write_to$  = .read_from$
        endif
        # Use the [.read_from$] path to determine the [participant]'s [.id$].
        @participant: .read_from$, .participant_number$
        # Read in the Segmented TextGrid.
        printline Loading Segmented TextGrid 'filename_from_pattern.filename$'
              ... from '.directory$'
        Read from file... '.read_from$'
        # Rename the Segmented TextGrid, and store this object's name.
        Rename... 'participant.id$'_Segm'.checking_initials$'
        .praat_obj$ = selected$()
        # Prepare the Segmented TextGrid to be checked by optionally adding
        # the 4 tiers for checking.
        printline Preparing '.praat_obj$' to be checked
        @prepare_segmented_textgrid: .praat_obj$
        if prepare_segmented_textgrid.ready_to_check
          select '.praat_obj$'
          Save as text file... '.write_to$'
        else
          .praat_obj$ = ""
        endif
      else   # no [.filename$] was found from the [.pattern$]
        # If no [.filename$] was found, then set the [.read_from$] and
        # [.write_to$] paths to empty strings.
        .read_from$ = ""
        .write_to$  = ""
        # Set the name of the [.praat_obj$] to an empty string as well.
        .praat_obj$ = ""
      endif
    else    # the [segmentation_log_is] not [.ready]
    endif


  # When tagging turbulence events...
  elif .activity$ == praat_activities.tag_turbulence$ |
       ... .activity$ == praat_activities.tag_burst$
    # Set up the path to the [.directory$] of checked segmented TextGrids.
    .directory$ = .experiment_directory$ + "/" +
              ... "Segmentation" + "/" +
              ... "TextGrids"
    # Set up the string [.pattern$] used to find a checked segmented TextGrid.
    .pattern$ = .directory$ + "/" +
            ... .experimental_task$ + "_" +
            ... .participant_number$ + "*" + "segm.TextGrid"
    # Search for a checked segmented TextGrid using the [.pattern$]
    @filename_from_pattern: .pattern$, "Segmented TextGrid"
    if filename_from_pattern.filename$ <> ""
      # Use the [.directory$] and [.filename$] strings to set up the path
      # from which the checked segmented TextGrid is [.read_from$].
      .read_from$ = .directory$ + "/" + filename_from_pattern.filename$
      # Use the [.read_from$] path to determine the [participant]'s [.id$].
      @participant: .read_from$, .participant_number$
      # Parse the checker's [.initials$] from the path that the TextGrid was
      # [.read_from$].
      .checkers_initials$ = mid$(.read_from$, rindex(.read_from$, "_") + 1, 2)
      # The [.write_to$] path is an empty string because any modifications to
      # the checked segmented TextGrid that are made during turbulence tagging
      # should be considered accidental and should not be saved.
      .write_to$ = ""
      # Read in the checked segmented TextGrid
      printline Loading Checked Segmented TextGrid
            ... 'filename_from_pattern.filename$' from '.directory$'
      Read from file... '.read_from$'
      Rename... 'participant.id$'_CheckedSegm'.checkers_initials$'
      .praat_obj$ = selected$()
    else
      # Set all string constants to empty strings.
      .read_from$ = ""
      .write_to$  = ""
      .praat_obj$ = ""
      # Print an error message.
      @segmentation_textgrid_error: .directory$, .participant_number$
    endif
  endif
endproc









