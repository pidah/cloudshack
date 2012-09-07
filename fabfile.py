"""
Simple python fabfile that does the following:
1. Provisions a specified number of ec2 instances
2. bootstraps the instance with puppet as specified in the user-data script
3. Configures the instance with jetty as defined in the puppet manifest
"""

from fabric.colors import green as _green, yellow as _yellow
from fabric.api import task
import boto
from string import Template
import boto.ec2
import time

# PUPPET_SOURCE plays the role of "Puppet Master".
PUPPET_SOURCE = 'https://github.com/pidah/cloudshack.git'

def get_script(filename='user-data-script.sh'):
    """
    grabs the user-data script
    """
    template = open(filename).read()
    return Template(template).substitute(
        puppet_source=PUPPET_SOURCE,
    )

@task
def launch_instance(count):
    """
    Provisions ec2 instance(s). For eg, to launch 3 instances you would run: 
    fab launch_instance:3   
    """
    print(_green("Started........"))
    print(_yellow("...............Creating EC2 instance(s)..."))
    
    conn = boto.connect_ec2(aws_access_key_id="AKIAJKCVNOUPF4YXDK6Q", 
    aws_secret_access_key="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")

    image = conn.get_all_images("ami-4b814f22")
 
    reservation = image[0].run(count, count, key_name="fabric", 
    security_groups=['default'], instance_type="m1.small", user_data=get_script())

    instance_list = reservation.instances
    
    print instance_list
   
    for instance in instance_list: 
        conn.create_tags([instance.id], {"Name":"jetty"})
        while instance.state == u'pending':
            print(_yellow("Instance state: %s" % instance.state))
            time.sleep(5)
            instance.update()

        print(_green("Instance state: %s" % instance.state))
        print(_green("Public dns: %s" % instance.public_dns_name))




