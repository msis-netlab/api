# api
NETLAB+ API
Author: Brad King
Date: 08/13/15

In order to support "personalized" NETLAB Pods, the Administrator must clone an existing Pod for each Student, create a Pod Assignment, and bring the Pod Online. Once the Class has finished, the Pod and associated VMs must be deleted.
There is no existing NETLAB+ API, and as such each Pod would need manual creation. Do this for 150 students per semester, and you'll hate life.

This repo simulates an API by wrapping HTTP calls to NETLAB+'s CGI scripts. Each CURL call has parameters substituted to the best of my ability, though their POST bodies are non-standard -- there are often large blocks of text submitted as a single variable, rather than pulling out each var. Regardless, it seems to be fit for the task.

Each script in the lib/ directory can be invoked on its own. Individual functions in lib/ are controlled by scripts living at the root of api/. There is currently no error checking, so a run through of expected results is necessary in order to confirm Pod, Assignment, and VM creation.

Despite the API supporting HOSTNAME as a parameter, they must be called within the NETLAB domain internall, so the VPN must be used.

Update are bound to come as the scripts are used in upcoming semesters.
