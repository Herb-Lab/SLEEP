#!/usr/bin/env python
# coding: utf-8

# # Modify one idf
# remember to change the pm2.5 file path

# In[37]:


def process_and_update_idf(file_path, new_co2_rate="0.0000000382", additional_text=""):
    # Read the original IDF file
    with open(file_path, 'r') as file:
        lines = file.readlines()

    new_lines = []
    in_people_block = False  # Flag for detecting "People" block

    # Process each line
    for line in lines:
        # Detect start of the People block
        if "People," in line:
            in_people_block = True

        # If in the People block and find Carbon Dioxide Generation Rate line, replace it
        if in_people_block and "!- Carbon Dioxide Generation Rate {m3/s-W}" in line:
            new_line = f"{new_co2_rate}, !- Carbon Dioxide Generation Rate {{m3/s-W}}\n"
            new_lines.append(new_line)
            in_people_block = False  # Exit the People block after replacement
            continue  # Skip to the next line

        # Replace Output CSV line
        if "!- Output CSV" in line:
            new_lines.append("Yes,!- Output CSV\n")
            continue  # Skip to the next line

        # Add Hourly reporting frequency line if it is not present already
        elif "!- Reporting Frequency" in line:
            if "Timestep" in line:
                new_lines.append("Hourly; !- Reporting Frequency\n")  # Add new line here as needed
                continue  # Skip to the next line
            if "timestep" in line:
                new_lines.append("Hourly; !- Reporting Frequency\n")  # Add new line here as needed
                continue  # Skip to the next line

        # For lines that do not match any condition, add them as is
        new_lines.append(line)

    # Write the modified lines back to the file
    with open(file_path, 'w') as file:
        file.writelines(new_lines)
    
    # Write the modified lines back to the file
    with open(file_path, 'w') as file:
        file.writelines(new_lines)
        # Append additional text
        file.write("\n" + additional_text)

    print("IDF file has been processed and updated.")

# Define the additional EMS and schedule text
additional_text = """
Schedule:File,
    PM25_outdoor,            !- Name
    Any number,              !- Schedule Type Limits Name
    /folder/PM25.csv,  !- directory of hourly outdoor PM2.5 concentration file
    3,                       !- Column Number
    1,                       !- Rows to Skip at Top
    8760,                    !- Number of Hours of Data
    Comma,                   !- Column Separator
    No,                      !- Interpolate to Timestep
    60,                      !- Minutes per Item
    Yes;                     !- Adjust Schedule for Daylight Savings

!- Sleep model_1
EnergyManagementSystem:ProgramCallingManager,
    SE85_ProgramManager_1,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
    SE85_program_1;            !- Program Name 1

EnergyManagementSystem:ProgramCallingManager,
    OSA5_ProgramManager_1,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
OSA5_program_1;            !- Program Name 1

EnergyManagementSystem:Program,
    SE85_program_1,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 0,       !- Program Line 2
    SET obesity = 0,         !- A4
    SET SE85_1 = -31.60174+0.54390*age_group + 0.30985 *obesity + 0.02532 * CO2 + 1.71910 * Twb -0.84615 * Tdp,  !- A5
    SET SE85_1 = @Exp (-SE85_1), !- A6
    SET SE85_1 = 1/(1+SE85_1);   !- A7

EnergyManagementSystem:Program,
    OSA5_program_1,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 0,       !- Program Line 2
    SET obesity = 0,         !- A4
    SET lnPM25 = @Ln (PM25 +1),  !- A5
    SET Ta=tin_s,    !- A6
    SET OSA5_1 = -5.68049+2.43323*age_group + 1.90478 *obesity + 2.07790 * lnPM25 - 0.61821* Ta+0.02994 * CO2,  !- A7
    SET OSA5_1 = @Exp (-OSA5_1), !- A8
    SET OSA5_1 = 1/(1+OSA5_1);   !- A9

EnergyManagementSystem:OutputVariable,
    SE85_prob_1,               !- Name
    SE85_1,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    SE85_program_1;            !- EMS Program or Subroutine Name

EnergyManagementSystem:OutputVariable,
    OSA5_prob_1,               !- Name
    OSA5_1,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    OSA5_program_1;            !- EMS Program or Subroutine Name

Output:Variable,
    EMS,                     !- Key Value
    SE85_prob_1,               !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    EMS,                     !- Key Value
    OSA5_prob_1,               !- Variable Name
    Hourly;                  !- Reporting Frequency

!- Sleep model_2
EnergyManagementSystem:ProgramCallingManager,
    SE85_ProgramManager_2,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
    SE85_program_2;            !- Program Name 1

EnergyManagementSystem:ProgramCallingManager,
    OSA5_ProgramManager_2,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
OSA5_program_2;            !- Program Name 1

EnergyManagementSystem:Program,
    SE85_program_2,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 0,       !- Program Line 2
    SET obesity = 1,         !- A4
    SET SE85_2 = -31.60174+0.54390*age_group + 0.30985 *obesity + 0.02532 * CO2 + 1.71910 * Twb -0.84615 * Tdp,  !- A5
    SET SE85_2 = @Exp (-SE85_2), !- A6
    SET SE85_2 = 1/(1+SE85_2);   !- A7

EnergyManagementSystem:Program,
    OSA5_program_2,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 0,       !- Program Line 2
    SET obesity = 1,         !- A4
    SET lnPM25 = @Ln (PM25 +1),  !- A5
    SET Ta=tin_s,    !- A6
    SET OSA5_2 = -5.68049+2.43323*age_group + 1.90478 *obesity + 2.07790 * lnPM25 - 0.61821* Ta+0.02994 * CO2,  !- A7
    SET OSA5_2 = @Exp (-OSA5_2), !- A8
    SET OSA5_2 = 1/(1+OSA5_2);   !- A9

EnergyManagementSystem:OutputVariable,
    SE85_prob_2,               !- Name
    SE85_2,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    SE85_program_2;            !- EMS Program or Subroutine Name

EnergyManagementSystem:OutputVariable,
    OSA5_prob_2,               !- Name
    OSA5_2,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    OSA5_program_2;            !- EMS Program or Subroutine Name

Output:Variable,
    EMS,                     !- Key Value
    SE85_prob_2,               !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    EMS,                     !- Key Value
    OSA5_prob_2,               !- Variable Name
    Hourly;                  !- Reporting Frequency

!- Sleep model_3
EnergyManagementSystem:ProgramCallingManager,
    SE85_ProgramManager_3,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
    SE85_program_3;            !- Program Name 1

EnergyManagementSystem:ProgramCallingManager,
    OSA5_ProgramManager_3,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
OSA5_program_3;            !- Program Name 1

EnergyManagementSystem:Program,
    SE85_program_3,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 1,       !- Program Line 2
    SET obesity = 0,         !- A4
    SET SE85_3 = -31.60174+0.54390*age_group + 0.30985 *obesity + 0.02532 * CO2 + 1.71910 * Twb -0.84615 * Tdp,  !- A5
    SET SE85_3 = @Exp (-SE85_3), !- A6
    SET SE85_3 = 1/(1+SE85_3);   !- A7

EnergyManagementSystem:Program,
    OSA5_program_3,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 1,       !- Program Line 2
    SET obesity = 0,         !- A4
    SET lnPM25 = @Ln (PM25 +1),  !- A5
    SET Ta=tin_s,    !- A6
    SET OSA5_3 = -5.68049+2.43323*age_group + 1.90478 *obesity + 2.07790 * lnPM25 - 0.61821* Ta+0.02994 * CO2,  !- A7
    SET OSA5_3 = @Exp (-OSA5_3), !- A8
    SET OSA5_3 = 1/(1+OSA5_3);   !- A9

EnergyManagementSystem:OutputVariable,
    SE85_prob_3,               !- Name
    SE85_3,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    SE85_program_3;            !- EMS Program or Subroutine Name

EnergyManagementSystem:OutputVariable,
    OSA5_prob_3,               !- Name
    OSA5_3,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    OSA5_program_3;            !- EMS Program or Subroutine Name

Output:Variable,
    EMS,                     !- Key Value
    SE85_prob_3,               !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    EMS,                     !- Key Value
    OSA5_prob_3,               !- Variable Name
    Hourly;                  !- Reporting Frequency

!- Sleep model_4
EnergyManagementSystem:ProgramCallingManager,
    SE85_ProgramManager_4,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
    SE85_program_4;            !- Program Name 1

EnergyManagementSystem:ProgramCallingManager,
    OSA5_ProgramManager_4,     !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
OSA5_program_4;            !- Program Name 1

EnergyManagementSystem:Program,
    SE85_program_4,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 1,       !- Program Line 2
    SET obesity = 1,         !- A4
    SET SE85_4 = -31.60174+0.54390*age_group + 0.30985 *obesity + 0.02532 * CO2 + 1.71910 * Twb -0.84615 * Tdp,  !- A5
    SET SE85_4 = @Exp (-SE85_4), !- A6
    SET SE85_4 = 1/(1+SE85_4);   !- A7

EnergyManagementSystem:Program,
    OSA5_program_4,            !- Name
    SET Twb= @TwbFnTdbWPb TIN_S WIN_S out_pb_s,  !- Program Line 1
    SET age_group = 1,       !- Program Line 2
    SET obesity = 1,         !- A4
    SET lnPM25 = @Ln (PM25 +1),  !- A5
    SET Ta=tin_s,    !- A6
    SET OSA5_4 = -5.68049+2.43323*age_group + 1.90478 *obesity + 2.07790 * lnPM25 - 0.61821* Ta+0.02994 * CO2,  !- A7
    SET OSA5_4 = @Exp (-OSA5_4), !- A8
    SET OSA5_4 = 1/(1+OSA5_4);   !- A9

EnergyManagementSystem:OutputVariable,
    SE85_prob_4,               !- Name
    SE85_4,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    SE85_program_4;            !- EMS Program or Subroutine Name

EnergyManagementSystem:OutputVariable,
    OSA5_prob_4,               !- Name
    OSA5_4,                    !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    OSA5_program_4;            !- EMS Program or Subroutine Name

Output:Variable,
    EMS,                     !- Key Value
    SE85_prob_4,               !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    EMS,                     !- Key Value
    OSA5_prob_4,               !- Variable Name
    Hourly;                  !- Reporting Frequency

!-Add PM2.5 and CO2 model on 
ZoneAirContaminantBalance,
    Yes,                     !- Carbon Dioxide Concentration
    CO2_outdoor,             !- Outdoor Carbon Dioxide Schedule Name
    Yes,                     !- Generic Contaminant Concentration
PM25_outdoor;            !- Outdoor Generic Contaminant Schedule Name

!- Add outdoor concentration schedule
ScheduleTypeLimits,
    Any number,              !- Name
    0,                       !- Lower Limit Value
    ,                        !- Upper Limit Value
    Continuous,              !- Numeric Type
Dimensionless;           !- Unit Type
Schedule:Constant,
    CO2_outdoor,             !- Name
    Any number,              !- Schedule Type Limits Name
400;                     !- Hourly Value

!- Add deposition 
ZoneContaminantSourceAndSink:Generic:DepositionRateSink,
    PM25_Deposition,         !- Name
    conditioned space,            !- Zone Name
    0.000125,                !- Deposition Rate {m/s}
    Always On Discrete;      !- Schedule Name

!- Add  EMS sensoer
EnergyManagementSystem:Sensor,
    PM25,                    !- Name
    conditioned space,            !- Output:Variable or Output:Meter Index Key Name
    Zone Air Generic Air Contaminant Concentration;  !- Output:Variable or Output:Meter Name

EnergyManagementSystem:Sensor,
    CO2,                     !- Name
    conditioned space,            !- Output:Variable or Output:Meter Index Key Name
    Zone Air CO2 Concentration;  !- Output:Variable or Output:Meter Name

EnergyManagementSystem:Sensor,
    Tdp,                     !- Name
    conditioned space,            !- Output:Variable or Output:Meter Index Key Name
Zone Mean Air Dewpoint Temperature;  !- Output:Variable or Output:Meter Name

!- Add  EMS program calling manager
EnergyManagementSystem:ProgramCallingManager,
    Zone_Mean_Air_Wetbulb_Temperature_ProgramManager,  !- Name
    EndOfZoneTimestepBeforeZoneReporting,  !- EnergyPlus Model Calling Point
    Zone_Mean_Air_Wetbulb_Temperature_program;  !- Program Name 1

!- Add EMS program
EnergyManagementSystem:Program,
    Zone_Mean_Air_Wetbulb_Temperature_program,  !- Name
    SET conditioned_space_wetbulb_temp = @TwbFnTdbWPb TIN_S WIN_S out_pb_s;  !- Program Line 1
   
!- Add EMS output
EnergyManagementSystem:OutputVariable,
    Zone Mean Air Wetbulb Temperature,  !- Name
    conditioned_space_wetbulb_temp,  !- EMS Variable Name
    Averaged,                !- Type of Data in Variable
    SystemTimestep,          !- Update Frequency
    Zone_Mean_Air_Wetbulb_Temperature_program,  !- EMS Program or Subroutine Name
    C;                       !- Units



!- Add output
Output:Variable,
    conditioned space,            !- Key Value
    Zone Air Generic Air Contaminant Concentration,  !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    conditioned space,            !- Key Value
    Zone Air CO2 Concentration,  !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    conditioned space,            !- Key Value
    Zone Mean Air Dewpoint Temperature,  !- Variable Name
    Hourly;                  !- Reporting Frequency

Output:Variable,
    EMS,                     !- Key Value
    Zone Mean Air Wetbulb Temperature,  !- Variable Name
    Hourly;                  !- Reporting Frequency


"""

