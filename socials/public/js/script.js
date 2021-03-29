function likeBtn(obj) {
  templiked = 'fa fa-heart fa-3x'
  temp = 'fa fa-heart-o fa-3x'
  if (obj.className == temp) {
    obj.className = templiked;
  }
  else {
    obj.className = temp;
  }
}

function seeposts() {
  imgpost = document.getElementsByClassName('imgposts')[0]
  textpost = document.getElementsByClassName('textposts')[0]
  if (imgpost.style.display == "none") {
    imgpost.style.display = "block";
    textpost.style.display = "none";
    document.querySelector('#profileButton').innerHTML = 'Written posts';
  }
  else {
    imgpost.style.display = "none";
    textpost.style.display = "block";
    document.querySelector('#profileButton').innerHTML = 'Image posts';
  }
}


function signInOption() {
  signup = document.getElementsByClassName('signUp')[0]
  logIn = document.getElementsByClassName('login')[0]
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