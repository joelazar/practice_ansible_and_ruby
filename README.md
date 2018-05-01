## Practice Ansible and Ruby

The main script is cli_script.rb. It's a cli script written in Ruby, using the Thor framework for cli functionalities. There is also a docker container built with build_docker.sh script which works as a rest server if you start it with start_docker.sh. But first, let me introduce the scripts functionalities:

    cli_script.rb commands:
    $ cli_script.rb create --private-key=PRIVATE_KEY

    It will create a new instance, where a LAMP stack will be installed and host a newly created drupal site.
    This script will start an ansible deployment by ansible/setup-ec2.yml playbook.
    --private-key is optional argument, if AWS_SSH_PRIVATE_KEY_PATH env variable is set on your host machine.
    For further information I recommend to read the command more detailed description.
            $ ./cli_script.rb help create

    $ cli_script.rb health

    Healthchecks the running drupal servers. It simply send a HTTP Get request to the instances and wait for 5 seconds for the response. Expected successful result is a HTTP 200.

    $ cli_script.rb list

    This command will print out every instance for an aws account, which is configured for this host.
    More info about AWS conf: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

    $ cli_script.rb suspend --iid=IID

    Suspends an instance with given instance id. iid is a must option for this command.

0. Common part
    Before testing this script, you have to set up ansible/vars/external_varibales.yml file.
    Change "keypair" to your aws keypair name and if you change region, you have to change the corresponding image hash too, because its different in every aws region.
    Of course, you have to have your aws account configured to your computer.

After the 0. step, you can choose between two seperate ways to start using this script.

1. The first way is to run it from your computer directly.

    If you choose this way, you have to install the ruby and python packages, which this solution depend on. And of course ruby and python itself :)

    For python packages:

        $ pip install -r requirements.txt

    For ruby packages:

        $ bundle install

    After this, start to use the script like this:

        $ ./cli_script.rb list

2. The second way is to run it in a docker container, as a rest server.

    Of course if you choose this way, you have to have an working docker service on your machine.
    You have to edit start_docker.sh, change "AWS_SSH_PRIVATE_KEY_PATH" to your own aws ssh key path.
    After this, you can start this script

        $ ./start_docker.sh

    At the first time executing this script, it will pull the latest image from gitlab's docker registry.
    This docker container's entrypoint will be the rest_server.rb file and you can access the http server through your own localhost:4567.

    You can test it with test_rest/send_http_request.rb ruby script too.
    It's a thor cli script, sends some basic http requests to the container and prints out the repsonses to the stdout. For it usage issue this commmand:

        $ ./test_rest/send_http_request.rb help

This script was created and tested on MacOS 10.10. However, it will surely smoothly work on every non-unorthodox linux distrubution too.

Restrictions:
But it will definitely not work on Windows.
