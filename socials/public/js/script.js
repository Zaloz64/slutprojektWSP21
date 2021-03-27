
function signInOption() {
  signup = document.getElementsByClassName('signUp')[0]
  logIn = document.getElementsByClassName('login')[0]
  console.log(document.querySelector('#signInOption').innerHTML);
  if (signup.style.display == "none") {
    signup.style.display = "block";
    logIn.style.display = "none";
    document.querySelector('#signInOption').innerHTML = 'Login';
  }
  else {
    signup.style.display = "none";
    logIn.style.display = "block";
    document.querySelector('#signInOption').innerHTML = 'Register';
  }
}

function filterFunction() {
  var input, filter, ul, li, a, i;
  input = document.querySelector('#myInput');
  filter = input.value.toUpperCase();
  a = document.querySelectorAll('.option');

  for (i = 0; i < a.length; i++) {
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {
      a[i].style.display = "";
    } else {
      a[i].style.display = "none";
    }
  }
}


function alerting() {
  console.log("wrong");
}