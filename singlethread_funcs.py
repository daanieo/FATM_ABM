import os

from lxml import etree
import xml.etree.ElementTree as ET

import tempfile
import numpy as np


def create_input_XML(unique_simulation_id, # changes every call
                     parameter_names,
                     parameter_values,
                     output_names,
                     stopping_condition,
                     experiment_name,
                     outputdir,
                     model_location_string,
                     GAMA_location_string):


    suffix=".xml"
    tempdir = tempfile.gettempdir()
    tempfile_location_string = tempdir+"/"+next(tempfile._get_candidate_names()) + suffix

    os.system("touch %s"%tempfile_location_string)

    # Make xml file
    Experiment_plan = etree.Element('Experiment_plan')

    # watch simulation id as a unique-maker of the
    Simulation = etree.SubElement(Experiment_plan, "Simulation",id=str(unique_simulation_id),sourcePath=model_location_string,until=str(stopping_condition),experiment=str(experiment_name))

    Parameters = etree.SubElement(Simulation,"Parameters")

    #insert loop for params
    if len(parameter_names) != len(parameter_values):
        raise ValueError
        print("names and values of parameters must be the same length")

    parameter_dict = {}
    for p_index in range(len(parameter_values)):
        parameter_dict[p_index] = etree.SubElement(Parameters,"Parameter",name=str(parameter_names[p_index]),type="FLOAT",value=str(parameter_values[p_index]))

    Outputs = etree.SubElement(Simulation,"Outputs")

    output_dict = {}
    for o_index in range(len(output_names)):
        output_dict[o_index] = etree.SubElement(Outputs,"Output",id="1",name=str(output_names[o_index]),framerate="1")

    tfile = open(tempfile_location_string,'wb')
    tfile.write(etree.tostring(Experiment_plan,xml_declaration=True,encoding="UTF-8",pretty_print=True))
    tfile.close()

    return tempfile_location_string


def run_model(unique_simulation_id,
              tempfile_location_string,
              GAMA_location_string,
              outputdir):

    launcher_string = "java -cp %s/plugins/org.eclipse.equinox.launcher*.jar -Xms512m -Xmx2048m -Djava.awt.headless=true org.eclipse.core.launcher.Main -application msi.gama.headless.id4 %s %s"
    # Everything % (gama location, input xml, output xml/dir)

    outputdir = "/tmp"
    #call gama
    a=os.system(launcher_string%(GAMA_location_string,tempfile_location_string,outputdir))
    print("Return value is ",a)
    print("$$",launcher_string%(GAMA_location_string,tempfile_location_string,outputdir))
    #
    # # delete input xml
    # bash_string = "rm %s"%tempfile_location_string
    # os.system(bash_string)

    return outputdir+"/"+ "simulation-outputs%s.xml"%unique_simulation_id




def parse_output_XML(unique_simulation_id,
                    output_location_string,
                     output_names):

    d = ET.parse(output_location_string)
    root = d.getroot()


    output_list = list()
    output_list.append(list()) # for unique simulation id
    for o in output_names:
        output_list.append(list())


    for step in root:
        output_list[0].append(unique_simulation_id)
        for variable in range(len(step)):
            output_list[variable+1].append(float(step[variable].text))

    bash_string = "rm %s"%output_location_string

    # also delete a weird .txt file, to be implemented
    os.system(bash_string)

    return output_list
